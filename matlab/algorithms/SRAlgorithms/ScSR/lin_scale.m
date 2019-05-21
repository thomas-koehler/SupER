function [xh] = lin_scale( xh, mNorm )

hNorm = sqrt(sum(xh.^2));

if hNorm,
    s = mNorm*1.2/hNorm;
    xh = xh.*s;
end