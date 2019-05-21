function impred =  runPatchVDSR(net, imlow, gpu, rf)
v = ceil(size(imlow, 1)/2);
h = ceil(size(imlow, 2)/2);

imTL = imlow(1:v+rf,   1:h+rf);
imBL = imlow(v-rf+1:end, 1:h+rf); 
imTR = imlow(1:v+rf,   h-rf+1:end);
imBR = imlow(v-rf+1:end, h-rf+1:end);

if gpu, imTL = gpuArray(imTL); end;
impredTL = runVDSR(net, imTL, gpu);
impredTL = impredTL(1:v, 1:h);

if gpu, imBL = gpuArray(imBL); end;
impredBL = runVDSR(net, imBL, gpu);
impredBL = impredBL(rf+1:end, 1:h);

if gpu, imTR = gpuArray(imTR); end;
impredTR = runVDSR(net, imTR, gpu);
impredTR = impredTR(1:v, rf+1:end);

if gpu, imBR = gpuArray(imBR); end;
impredBR = runVDSR(net, imBR, gpu);
impredBR = impredBR(rf+1:end, rf+1:end);

impredL = cat(1, impredTL, impredBL);
impredR = cat(1, impredTR, impredBR);
impred = cat(2, impredL, impredR);