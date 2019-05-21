#include <mex.h>
#include <math.h>
#include <vector>

using namespace std;

/**
    A struct to represent 2-D pixel coordinates.
*/
typedef struct
{
    double x;
    double y;
} Pixel;

/**
    A struct to represent the size of an image.
*/
typedef struct ImageSize
{
    int dimX;
    int dimY; 
    int numel() const
    {
        return dimX * dimY;
    }
} ImageSize;

/**
    A struct to represent static imaging parameters: PSF and image dimensions.
*/
typedef struct CameraParameters
{
    double psfWidth;
    ImageSize lrDimension;
    ImageSize hrDimension;
    
} CameraParameters;

#define ROUND_UINT(d) ( (unsigned int) ((d) + ((d) > 0 ? 0.5 : -0.5)) )

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void ParseHomography(const mxArray* rawArray, double* H);
void ParseDisplacementField(const mxArray* rawArray, vector<double>* vx, vector<double>* vy);
vector<Pixel> GetPixelCoordinates(int dimY, int dimX);
mxArray* AllocateSystemMatrix(int m, int n, mwSize* nzmax);
void ReallocateSystemMatrix(mxArray* systemMat, mwSize oldSize, mwSize* newSize);
void TransformByHomography(const CameraParameters& camParams, const double* H, const vector<Pixel>& lrPixels, vector<Pixel>* lrPixelsTrans);
void TransformByDisplacementField(const CameraParameters& camParams, vector<double>& vx, vector<double>& vy, const vector<Pixel>& lrPixels, vector<Pixel>* lrPixelsTrans);
mxArray* ComposeSystemMatrix(const CameraParameters& camParams, vector<Pixel>& lrPixelVecTrans, vector<Pixel>& hrPixelVec);

/**
    The MEX function imlementing the composition of the system matrix.
    - prhs contains pointers to the static image parameters and a 3x3 homography.
        
        The imaging parameters are expected to be stored in an array
        [LR rows; LR colums; HR rows; HR colums; PSF standard deviation]
 
        The motion parameters are expected to be stored in a 3x3 array H
        such that p' = H * p is the transformed point p in the format
        p = [y; x; 1] (homogeneous coordinates).
 
    - plhs contains the sparse system matrix.
*/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
    CameraParameters camParams;
            
    // Get the dimension of a LR frame.
    double* lrDimensionArray = mxGetPr(prhs[0]);
    ImageSize lrDimension;
    lrDimension.dimY = (int) *lrDimensionArray;
    lrDimension.dimX = (int) *(lrDimensionArray + 1); 
    camParams.lrDimension = lrDimension;

    // Get magnification factor
    double zoom = *(mxGetPr(prhs[1]));
    camParams.hrDimension.dimX = (int) (zoom * camParams.lrDimension.dimX);
    camParams.hrDimension.dimY = (int) (zoom * camParams.lrDimension.dimY);
    
    // Get width of Gaussian PSF
    camParams.psfWidth = *(mxGetPr(prhs[2]));
    
    // Pre-compute sequences of 2-D pixel coordinates of the LR- and the HR-grid.
    vector<Pixel> lrPixelVec = GetPixelCoordinates(camParams.lrDimension.dimY, camParams.lrDimension.dimX);
    vector<Pixel> hrPixelVec = GetPixelCoordinates(camParams.hrDimension.dimY, camParams.hrDimension.dimX);
    vector<Pixel> lrPixelVecTrans = vector<Pixel>(lrPixelVec.size());
    
    // Parse motion parameters
    if (!mxIsStruct(prhs[3]))
    {
        // Motion is given by 3x3 homography.
        double* motion = new double[9];
        ParseHomography(prhs[3], motion);
        
        // Transform all pixel coordinates from LR image grid to HR grid in reference frame.
        TransformByHomography(camParams, motion, lrPixelVec, &lrPixelVecTrans);
    }
    else 
    {
        // Motion is given by a displacement vector field.
        vector<double> vx; 
        vector<double> vy;
        ParseDisplacementField(prhs[3], &vx, &vy);
        
         // Transform all pixel coordinates from LR image grid to HR grid in reference frame.
        TransformByDisplacementField(camParams, vx, vy, lrPixelVec, &lrPixelVecTrans);
    }
    
    plhs[0] = ComposeSystemMatrix(camParams, lrPixelVecTrans, hrPixelVec);
}

/**
    Parse the 3x3 homography in a common C matrix.
*/
void ParseHomography(const mxArray* rawArray, double* H)
{
    double* data = mxGetPr(rawArray);
	H[0] = data[0];
	H[1] = data[3];
	H[2] = data[6];
	H[3] = data[1];
	H[4] = data[4];
	H[5] = data[7];
	H[6] = data[2];
	H[7] = data[5];
	H[8] = data[8];
}

void ParseDisplacementField(const mxArray* rawArray, vector<double>* vx, vector<double>* vy)
{
    mxArray* vxArrayRaw = mxGetField(rawArray, 0, "vx");
    double* vxArray = mxGetPr(vxArrayRaw);
    mxArray* vyArrayRaw = mxGetField(rawArray, 0, "vy");
    double* vyArray = mxGetPr(vyArrayRaw);
    
    const mwSize* size = mxGetDimensions(vxArrayRaw);
    
    for (int row = 0; row < size[0]; row++)
    {
        for (int col = 0; col < size[1]; col++)
        {            
            vx->push_back(vxArray[col*size[0] + row]);
            vy->push_back(vyArray[col*size[0] + row]);
        }
    }  
}

/**
    Create a linearzied sequence of 2-D pixel coordinates for an image 
    with a given size.
*/
vector<Pixel> GetPixelCoordinates(int dimY, int dimX)
{
    vector<Pixel> pixelCoords;
    for (int y = 0; y < dimY; y++)
    {
        for (int x = 0; x < dimX; x++)
        {
            Pixel p;
            p.x = x;
            p.y = y;
            pixelCoords.push_back(p);
        }  
    }
    return pixelCoords;
}

/**
    Compose the sparse system matrix for given motion and imaging 
    parameters.
 
    Note: The calculated system matrix is in transposed order. To use it
    in super-resolution we have to transpose this matrix or change the
    order of matrices and vectors in matrix/vector products.
*/
mxArray* ComposeSystemMatrix(const CameraParameters& camParams, vector<Pixel>& lrPixelVecTrans, vector<Pixel>& hrPixelVec)
{
    int m = camParams.lrDimension.numel();
    int n = camParams.hrDimension.numel();
	double zoom = (double) 1.0 * camParams.hrDimension.dimX / camParams.lrDimension.dimX;
	double maxPsfRadius = 3*zoom*camParams.psfWidth; 

    // Allocate memory for system matrix and get pointers to array structure.
    mwSize nzmax;
    mxArray* systemMat = AllocateSystemMatrix(n, m, &nzmax);
    double* sr  = mxGetPr(systemMat);
    mwIndex* irs = mxGetIr(systemMat);
    mwIndex* jcs = mxGetJc(systemMat);
                                                                                                                                                                                                                                                         
    // Calculate elements of system matrix.
    mwIndex k = 0;
    // Iterate over all LR pixels.
    for (mwSize j = 0; j < m; j++)
    {
        jcs[j] = k;

		// Get the coordinates of the LR pixel in the HR grid.
        Pixel hrPixel = lrPixelVecTrans[j];
        
        // Iterate over all pixels in the neighbourhood affected by the PSF.
        for (int delta_y = -maxPsfRadius; delta_y <= maxPsfRadius; delta_y++)
        {
            for (int delta_x = -maxPsfRadius; delta_x <= maxPsfRadius; delta_x++)
            {
                // Get the current neighbour at an integer pixel position.
                Pixel hrPixelNeighbour = hrPixel;
                hrPixelNeighbour.x = ROUND_UINT(hrPixel.x + delta_x);
                hrPixelNeighbour.y = ROUND_UINT(hrPixel.y + delta_y);
                
                // Check if the current neighbour is inside the HR image.
                if ( (hrPixelNeighbour.x >= 0) && (hrPixelNeighbour.x < camParams.hrDimension.dimX) && (hrPixelNeighbour.y >= 0) && (hrPixelNeighbour.y < camParams.hrDimension.dimY) )
                {
                    // Get the index of this neighbour in a 1-D linearzied version of the image.
                    mwSize i = hrPixelNeighbour.y * camParams.hrDimension.dimX + hrPixelNeighbour.x;
				
                    // Calculate the distance between the selected center pixel and the neighbour pixel to evaluate the PSF.
                    double d[2]; 
                    d[0] = lrPixelVecTrans[j].x - hrPixelNeighbour.x;
                    d[1] = lrPixelVecTrans[j].y - hrPixelNeighbour.y;
                    double dist = d[0]*d[0] + d[1]*d[1];
                            
                    // Evaluate weight for the current element using the transformed isotropic Gaussian PSF.
                    double weight = exp( -dist / (2*zoom*zoom*camParams.psfWidth*camParams.psfWidth) );
                    
                    // Check to see if non-zero element will fit in allocated output array.
                    if (k >= nzmax)
                    {   
						// We have to reallocate the system matrix (increase number of non-zero elements).
                        ReallocateSystemMatrix(systemMat, nzmax, &nzmax);        
                        sr = mxGetPr(systemMat); // Get pointer to reallocated sparse matrix data
                        irs = mxGetIr(systemMat); 
                    }
                
                    // Write new weight factor to current matrix position.
                    sr[k] = weight;
                    irs[k] = i;     // We have found a row with an non-zero element.     
                    k++;
                }
            }
        }
    }
    jcs[m] = k;
        
    return systemMat;  
}

/**
    Allocate the m x n system matrix
*/
mxArray* AllocateSystemMatrix(int m, int n, mwSize* nzmax)
{
    // Set the percentage of non-zero elements in the sparse matrix. 
    double percent_sparse = (15.0*n) / (1.0*m*n);
    mwSize nz = (mwSize)ceil((double)m*(double)n*percent_sparse);
    if (nz < 10)
    {
        nz = 10;
    }
    // Allocate the memory and return the sparse matrix instance.
    mxArray* systemMat = mxCreateSparse(m, n, nz, mxREAL);
    *nzmax = nz;
    return systemMat;
}

/**
    Re-allocate the system matrix if the maximum number of non-zero
    is exceeded.
*/
void ReallocateSystemMatrix(mxArray* systemMat, mwSize oldSize, mwSize* newSize)
{
    // Increase size of sparse matrix by 10%
    mwSize s = (mwSize) ceil(1.1 * oldSize);
    // Make sure nzmax increases at least by 1
    if (oldSize == s) 
    {
        s++;
    }             
    // Memory reallocation
    mxSetNzmax(systemMat, s);
    double* data = mxGetPr(systemMat);
    mwIndex* irs = mxGetIr(systemMat); 
    mxSetPr(systemMat, (double*) mxRealloc(data , s*sizeof(double)));
    mxSetIr(systemMat, (mwIndex*) mxRealloc(irs, s*sizeof(mwIndex)));
    *newSize = s;   
}

/**
    Transform pixel coordinates from the LR-grid to the desired HR-grid.
*/
void TransformByHomography(const CameraParameters& camParams, const double* H, const vector<Pixel>& lrPixels, vector<Pixel>* lrPixelsTrans)
{
    double zoom = (double) 1.0 * camParams.hrDimension.dimX / camParams.lrDimension.dimX;
    for (int k = 0; k < lrPixels.size(); k++)
    {
        (*lrPixelsTrans)[k].x = (H[0] * lrPixels[k].x + H[1] * lrPixels[k].y + H[2]) * zoom + 0.5*(zoom-1);
        (*lrPixelsTrans)[k].y = (H[3] * lrPixels[k].x + H[4] * lrPixels[k].y + H[5]) * zoom + 0.5*(zoom-1);
    }
}

void TransformByDisplacementField(const CameraParameters& camParams, vector<double>& vx, vector<double>& vy, const vector<Pixel>& lrPixels, vector<Pixel>* lrPixelsTrans)
{
    double zoom = (double) 1.0 * camParams.hrDimension.dimX / camParams.lrDimension.dimX;
    for (int k = 0; k < lrPixels.size(); k++)
    {
        (*lrPixelsTrans)[k].x = zoom * (lrPixels[k].x + vx[k]) + 0.5*(zoom-1);
        (*lrPixelsTrans)[k].y = zoom * (lrPixels[k].y + vy[k]) + 0.5*(zoom-1);
    }    
}