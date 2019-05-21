function [pixels, details] = readdpx1(filename)

% Validate input argument.
if (~ischar(filename))
    error('Filename must be a character array');
end

% Read entire file into a UINT8 buffer.
buffer = getBufferFromFile(filename);

[isValid, swapFcn] = isValidDPX(buffer);
if (~isValid)
    error('Bad magic number.  The file may not be valid DPX.');
end

% Extract metadata and pixels from the buffer.
details = getDetailsFromBuffer(buffer, swapFcn);
pixels = readPixels(buffer, details, swapFcn);



%------------------------------------------------------------------------
function buffer = getBufferFromFile(filename)

fid = fopen(filename, 'r');
if (fid == -1)
    error('Could not open file %s for reading.', filename);
end

% Read the whole file into a UINT8 buffer and then tease out the parts
% as needed.
buffer = fread(fid, inf, 'uint8=>uint8');

fclose(fid);



%------------------------------------------------------------------------
function [tf, swapFcn] = isValidDPX(buffer)

% DPX files should begin with a 4-byte magic number (the ASCII bytes for
% SDPX or XPDS).  We can use these values to validate the file and
% determine the endianness.
expectedMagicNumber = uint32(sscanf('53445058', '%x'));
fileMagicNumber = typecast(buffer(1:4), 'uint32');

if isequal(fileMagicNumber, expectedMagicNumber)
   tf = true;
   swapFcn = @(x) x;
   
elseif isequal(swapbytes(fileMagicNumber), expectedMagicNumber)
   tf = true;
   swapFcn = @(x) swapbytes(x);
   
else
   tf = false;
   swapFcn = [];
end



%------------------------------------------------------------------------
function details = getDetailsFromBuffer(allData, swapFcn)

details = struct([]);

details(1).FileDetails = getFileDetails(allData, swapFcn);
details(1).ImageDetails = getImageDetails(allData, swapFcn);
details(1).ImageOrientation = getOrientation(allData, swapFcn);
details(1).IndustryDetails = getIndustryDetails(allData, swapFcn);



%------------------------------------------------------------------------
function fileDetails = getFileDetails(buffer, swapFcn)
        
dataStructure = {...
       0,   1, 'uint32', 'MagicNumber'
       4,   1, 'uint32', 'ImageDataOffset'
       8,   8, 'char',   'HeaderVersion'
      16,   1, 'uint32', 'FileSize'
      20,   1, 'uint32', 'ReadTimeShortCut'
      24,   1, 'uint32', 'GenericHeaderSize'
      28,   1, 'uint32', 'IndustryHeaderSize'
      32,   1, 'uint32', 'UserDefinedDataSize'
      36, 100, 'char',   'ImageFilename'
     136,  24, 'char',   'CreateTime'
     160, 100, 'char',   'Creator'
     260, 200, 'char',   'Project'
     460, 200, 'char',   'Copyright'
     660,   1, 'uint32', 'Key'
     664, 104, 'char',   'Reserved'};
 
fileDetails = parseDataStructure(buffer, dataStructure, swapFcn);



%------------------------------------------------------------------------
function imageDetails = getImageDetails(buffer, swapFcn)

dataStructure = {...
     768,    1, 'uint16', 'Orientation'
     770,    1, 'uint16', 'NumberOfImageElements'
     772,    1, 'uint32', 'Columns'
     776,    1, 'uint32', 'Rows'
     780, 8*72, 'uint8',  'ImageElementDetails'
    1356,   52, 'uint8',  'Reserved'};

elementSubStructure = {...
     0,  1, 'uint32', 'SignedImages'
     4,  1, 'uint32', 'ReferenceLowDataCodeValue'
     8,  1, 'single', 'ReferenceLowQuantity'
    12,  1, 'uint32', 'ReferenceHighDataCodeValue'
    16,  1, 'single', 'ReferenceHighQuantity'
    20,  1, 'uint8',  'Descriptor'
    21,  1, 'uint8',  'TransferCharacteristics'
    22,  1, 'uint8',  'Colorimetry'
    23,  1, 'uint8',  'BitSize'
    24,  1, 'uint16', 'Packing'
    26,  1, 'uint16', 'Encoding'
    28,  1, 'uint32', 'DataOffset'
    32,  1, 'uint32', 'EndOfLinePadding'
    36,  1, 'uint32', 'EndOfImagePadding'
    40, 32, 'char',   'Description'};

% Parse the top-level structure from this part of the buffer.
imageDetails = parseDataStructure(buffer, dataStructure, swapFcn);

% Parse the eight Image Element Details data structures from the
% ImageElement field.
elementBuffer = imageDetails.ImageElementDetails;

for elementNumber = 1:8
    
    elementBufferStart = (elementNumber - 1) * 72 + 1;
    elementBufferEnd = elementNumber * 72;
    
    tmpBuffer = elementBuffer(elementBufferStart:elementBufferEnd);
    imageDetails.ImageElementDetailsParsed(elementNumber) = ...
        parseDataStructure(tmpBuffer, elementSubStructure, swapFcn);
    
end



%------------------------------------------------------------------------
function orientationDetails = getOrientation(buffer, swapFcn)
        
dataStructure = {...
    1408,   1, 'uint32', 'XOffset'
    1412,   1, 'uint32', 'YOffset'
    1416,   1, 'single', 'XCenter'
    1420,   1, 'single', 'YCenter'
    1424,   1, 'uint32', 'XOriginalSize'
    1428,   1, 'uint32', 'YOriginalSize'
    1432, 100, 'char',   'SourceImageFilename'
    1532,  24, 'char',   'SourceImageCreationTime'
    1556,  32, 'char',   'InputDeviceName'
    1588,  32, 'char',   'InputDeviceSerialNumber'
    1620,   4, 'uint16', 'BorderValidity'
    1628,   2, 'uint32', 'PixelAspectRatio'
    1636,  28, 'uint8',  'Reserved'};

orientationDetails = parseDataStructure(buffer, dataStructure, swapFcn);



%------------------------------------------------------------------------
function industryDetails = getIndustryDetails(buffer, swapFcn)

% There is more information in the DPX standard for this, but it doesn't
% affect how to read the file.
industryDetails = [];
    
    
    
%------------------------------------------------------------------------
function details = parseDataStructure(buffer, dataStructure, swapFcn)

details = struct([]);

% For each part of the data structure, extract data from the buffer,
% transform it, and store it in the output structure.
for fieldNumber = 1:size(dataStructure, 1)
    
    thisField = dataStructure(fieldNumber, :);
    name = thisField{4};
    
    details(1).(name) = getData(buffer, thisField, swapFcn);
    
end



%------------------------------------------------------------------------
function data = getData(buffer, fieldDetails, swapFcn)

% Find the offset and extent to this data element in the buffer.
% The data structure offsets are 0-based, and MATLAB is 1-based.
dataStart = fieldDetails{1} + 1;
datatype = fieldDetails{3};
dataEnd = fieldDetails{1} + fieldDetails{2} * sizeof(datatype);

rawData = buffer(dataStart:dataEnd);

% ASCII character data in the file is 8-bit and is not converted.
if (strcmp(datatype, 'char'))
    data = char(rawData)';
else
    data = swapFcn(typecast(rawData, datatype));
end



%------------------------------------------------------------------------
function numBytes = sizeof(datatype)

switch (datatype)
    case {'char', 'uint8', 'int8'}
        numBytes = 1;
        
    case {'uint16', 'int16'}
        numBytes = 2;
        
    case {'uint32', 'int32', 'single'}
        numBytes = 4;
        
    case {'uint64', 'int64', 'double'}
        numBytes = 8;
        
    otherwise
        error('Unknown datatype %s.', datatype)
        
end



%------------------------------------------------------------------------
function pixels = readPixels(buffer, details, swapFcn)

% Do we support this colorspace or data arrangement?
%
% There are many ways of organizing samples inside of DPX files.  This
% example code handles RGB and grayscale data (each with a linear
% response).  Other varieties include YCbCr colorspaces and RGB images
% stored one color sample per image element.  Nonlinear response curves can
% also be used.
descriptor = details.ImageDetails.ImageElementDetailsParsed(1).Descriptor;
switch (descriptor)
    case 6
        numChannels = 1;
        
    case 50
        numChannels = 3;
        
    otherwise
        error('Unsupported DPX format: %d', descriptor)
        
end

% Determine sizes and sample locations.
rows = details.ImageDetails.Rows;
columns = details.ImageDetails.Columns;
bitDepth = details.ImageDetails.ImageElementDetailsParsed(1).BitSize;

startOfPixels = details.FileDetails.ImageDataOffset;
if bitDepth == 10
    endOfPixels = startOfPixels + ...
        double(rows * columns) * numChannels * 4/3;    
else
    endOfPixels = startOfPixels + ...
        double(rows * columns) * numChannels * double(bitDepth)/8;
end

% Convert the buffer to an array of output pixels.
%
% DPX files can also contain bit-depths that cause pixel samples not to end
% on byte boundaries (e.g., 10-bit and 12-bit images).  We won't handle
% them in this example, since the padding details could be confusing.
switch bitDepth
    case 8
        pixels = buffer((startOfPixels + 1):endOfPixels);

    case 16
        pixels = typecast(buffer((startOfPixels + 1):endOfPixels), 'uint16');
        pixels = swapFcn(pixels);

    case 10
        three_pixels = typecast(buffer((startOfPixels + 1):endOfPixels), 'uint32');
        pixels = zeros(1,length(three_pixels)*3);
        for i = 1:length(three_pixels)
            tmp = three_pixels(i);
            if 1
                tmp0 = bitshift(tmp,-22);
                tmp1 = bitshift(tmp,-12);
                tmp2 = bitshift(tmp,-2);
                pix0 = bitand(1023,tmp0);
                pix1 = bitand(1023,tmp1);
                pix2 = bitand(1023,tmp2);
                pixels(i*3-2) = uint16(pix0);
                pixels(i*3-1) = uint16(pix1);
                pixels(i*3) = uint16(pix2);
            else
                tmp0 = bitshift(tmp,-24);
                tmp1 = bitshift(tmp,-14);
                tmp2 = bitshift(tmp,-4);
                pix0 = bitand(255,tmp0);
                pix1 = bitand(255,tmp1);
                pix2 = bitand(255,tmp2);
                pixels(i*3-2) = uint8(pix0);
                pixels(i*3-1) = uint8(pix1);
                pixels(i*3) = uint8(pix2);
            end
        end
        rows = length(three_pixels) / columns;
        

    otherwise
        error('Unsupported bit-depth.');
        
end

% Rearrange the data to follow MATLAB's conventions.
pixels = reshape(pixels, [numChannels, columns, rows]);
pixels = permute(pixels, [3 2 1]);