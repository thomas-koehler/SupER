function fe=fecal(im)
    rf=dct2(im);
    rf(1,1)=0.00000001;
    nrf=rf.^2/sum(sum(rf.^2));
    nrf(nrf==0)=0.00000001;
    fe=-sum(sum(nrf.*log2(nrf)));
return;