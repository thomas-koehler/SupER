function [fw_mvs_xc, bw_mvs_xc] = lmsSR_computeMotionVectorXCheck(fw_mvs, bw_mvs)
%
% LMSSR_COMPUTEMOTIONVECTORXCHECK Performs a cross-check between the forward and backward motion vector field.
%    [fw_mvs_xc, bw_mvs_xc] = LMSSR_COMPUTEMOTIONVECTORXCHECK(fw_mvs, bw_mvs)
%
% Parameters: fw_mvs      -   Forward Motion Vector Field
%             bw_mvs      -   Backward Motion Vector Field
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

[height,width,~] = size(fw_mvs);

%% Solution One

fw_mvs_xc = fw_mvs;

for iteraY = 1:height,
    for iteraX = 1:width,
        fw_shift     = squeeze(fw_mvs(iteraY,iteraX,:));
        fw_float_pos = [iteraX; iteraY] + fw_shift;
        round_pos    = round(fw_float_pos);
        delta_pos    = round_pos - fw_float_pos;
        
        if round_pos(1) < 1 || round_pos(1) > width || round_pos(2) < 1 || round_pos(2) > height,
            fw_mvs_xc(iteraY,iteraX,1) = NaN;
            fw_mvs_xc(iteraY,iteraX,2) = NaN;
            continue;
        end
        
        bw_shift         = squeeze(bw_mvs(round_pos(2),round_pos(1),:));
        bw_float_pos     = round_pos + bw_shift;
        bw_float_pos_cor = bw_float_pos - delta_pos;
        checked_pos      = round(bw_float_pos_cor);
        
        if ~(checked_pos(1) == iteraX) && (checked_pos(2) == iteraY),
            fw_mvs_xc(iteraY,iteraX,1) = NaN;
            fw_mvs_xc(iteraY,iteraX,2) = NaN;
        end
    end
end

bw_mvs_xc = bw_mvs;

for iteraY = 1:height,
    for iteraX = 1:width,
        bw_shift     = squeeze(bw_mvs(iteraY,iteraX,:));
        bw_float_pos = [iteraX; iteraY] + bw_shift;
        round_pos    = round(bw_float_pos);
        delta_pos    = round_pos - bw_float_pos;
        
        if round_pos(1) < 1 || round_pos(1) > width || round_pos(2) < 1 || round_pos(2) > height,
            bw_mvs_xc(iteraY,iteraX,1) = NaN;
            bw_mvs_xc(iteraY,iteraX,2) = NaN;
            continue;
        end
        
        fw_shift         = squeeze(fw_mvs(round_pos(2),round_pos(1),:));
        fw_float_pos     = round_pos + fw_shift;
        fw_float_pos_cor = fw_float_pos - delta_pos;
        checked_pos      = round(fw_float_pos_cor);
        
        if ~(checked_pos(1) == iteraX) && (checked_pos(2) == iteraY),
            bw_mvs_xc(iteraY,iteraX,1) = NaN;
            bw_mvs_xc(iteraY,iteraX,2) = NaN;
        end
    end
end

