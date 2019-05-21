
 h = [0 0.1 0.2; 0.1 0.2 0.1; 0 0.1 0.2];
 
 result_conv = cconv2d(h,J0);
 figure(1), imshow(result_conv)
 result_convt = cconv2d(h',J0);
 figure(2), imshow(result_convt);
 result_convt2 = cconv2dt(h,J0);
 figure(3), imshow(result_convt2);
 
 