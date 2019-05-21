function impred =  runPatchDRCN(net, imlow, gpu, rf)
v = ceil(size(imlow, 1)/2);
h = ceil(size(imlow, 2)/2);

imTL = imlow(1:v+rf,   1:h+rf);
imBL = imlow(v-rf+1:end, 1:h+rf); 
imTR = imlow(1:v+rf,   h-rf+1:end);
imBR = imlow(v-rf+1:end, h-rf+1:end);

if gpu, imTL = gpuArray(imTL); end;
impredTL = runDRCN(net, imTL, gpu); % MAGI-FIX: runRCN
impredTL = impredTL(1:v, 1:h);

if gpu, imBL = gpuArray(imBL); end;
impredBL = runDRCN(net, imBL, gpu); % MAGI-FIX: runRCN
impredBL = impredBL(rf+1:end, 1:h);

if gpu, imTR = gpuArray(imTR); end;
impredTR = runDRCN(net, imTR, gpu); % MAGI-FIX: runRCN
impredTR = impredTR(1:v, rf+1:end);

if gpu, imBR = gpuArray(imBR); end;
impredBR = runDRCN(net, imBR, gpu); % MAGI-FIX: runRCN
impredBR = impredBR(rf+1:end, rf+1:end);

impredL = cat(1, impredTL, impredBL);
impredR = cat(1, impredTR, impredBR);
impred = cat(2, impredL, impredR);

