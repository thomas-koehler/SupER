function impred = runVDSR(net, imlow, gpu)
net2.layers = net.layers(1:end-1);
res2 = vl_simplenn(net2, imlow, []);% {'conserveMemory', true});
impred = res2(end).x;
impred = imlow+impred;
if gpu, impred = gather(impred); end