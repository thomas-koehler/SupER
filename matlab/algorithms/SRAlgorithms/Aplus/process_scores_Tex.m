function process_scores_Tex(conf, scores, nr)

fprintf('Writing results to Tex summary...\n');

valid_id = [2 3 4 5 6 7 8 9 11];
fprintf('\n');

    for j = 1:length(conf.desc)
        if sum(valid_id==j)==0
            continue;
        end;
        fprintf('& \\multicolumn{2}{|c|}{%s}', conf.desc{j});        
    end
    fprintf('\\\\\n');

fprintf('image');
    for j = 1:length(conf.desc)
        if sum(valid_id==j)==0
            continue;
        end;
        fprintf('& PSNR & Time');        
    end
    fprintf('\\\\\n');

for i =1:nr
    [p, f, x] = fileparts(conf.filenames{i});
    fprintf('%s',f);
    for j = 1:length(conf.desc)
        if sum(valid_id==j)==0
            continue;
        end;
        
        fprintf(' & %.1f & %.1f', scores(i,j), conf.countedtime(j-1,i));
    end
    fprintf('\\\\\n');
end

fprintf('average');
for j = 1:11
    if sum(valid_id==j)==0
       continue;
    end;
     
    fprintf(' & %.2f & %.2f', mean(scores(:,j)), mean(conf.countedtime(j-1,:)));
end
fprintf('\\\\\n\n\n');
