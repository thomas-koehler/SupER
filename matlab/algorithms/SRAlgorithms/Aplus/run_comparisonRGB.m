function run_comparisonRGB(conf)
% The results are written into HTML report, together with thumbnails

fid = fopen(fullfile(conf.result_dirRGB, 'index.html'), 'wt');
fprintf(fid, ...
    '<HTML><HEAD><TITLE>Super-Resolution Summary</TITLE></HEAD><BODY>');

fprintf(fid, '<H1>Simulation results, RGB</H1>\n');

%conf.calc = @calc_PeakSNR_nob;
conf.calc = @calc_PeakSNR;
conf.units = 'dB';
calc_performance = @(f, g) ...
    conf.calc(fullfile(conf.result_dirRGB, f), fullfile(conf.result_dirRGB, g));
metric = sprintf('%s [%s]', strrep(func2str(conf.calc), 'calc_', ''), conf.units);
fprintf(fid, metric);
% Table header
fprintf(fid, '<TABLE border="1">\n');
fprintf(fid, '<TR>');
for i = 1:numel(conf.desc)
    fprintf(fid, '<TD>%s</TD>', conf.desc{i});
end
fprintf(fid, '</TR>\n');

image_write = @(image, filename) ...
    imwrite(image, fullfile(conf.result_dirRGB, filename));

fprintf('Writing RGB results to HTML summary...\n');
scores = zeros(numel(conf.filenames),numel(conf.results{1}));
for i = 1:numel(conf.filenames)        
    fprintf('%d/%d:', i, numel(conf.filenames));
    
    for j = 1:numel(conf.results{i})
        [dummy, f] = split_path(conf.resultsRGB{i}{j});
        image_write(imread(conf.resultsRGB{i}{j}), f);
        conf.resultsRGB{i}{j} = f;
    end

    X = imread(conf.filenames{i}); 
    [p, f, x] = fileparts(conf.filenames{i});
    f0 = [f '[0-Thumb].png'];
    fprintf(fid, '<TR><TD><A HREF=%s><IMG SRC=%s TITLE="%s"></A></TD>\n', ...
        esc(conf.resultsRGB{i}{1}), f0, f);
    X = X(:, :, 1, 1); % Take the original and scale it down to a 64x64 thumbnail
    image_write(imresize(X, round(64*size(X)/size(X, 2))), f0);
    
    fprintf('\t[%s]', f);    
    for j = 2:numel(conf.results{i})
        score = calc_performance(conf.resultsRGB{i}{1}, conf.resultsRGB{i}{j});
        scores(i,j) = score;
        fprintf(fid, '<TD><A HREF=%s>%.1f</A>(%.2f)</TD>\n', ...
            esc(conf.resultsRGB{i}{j}), score, conf.countedtime(j-1,i));
        fprintf(' : %.1f dB', score)
    end
    fprintf(fid, '</TR>\n');
    fprintf('\n');
end
fprintf(fid, '<TR><TD>Average PSNR</TD>\n');
mscores = mean(scores);
fprintf('\tAverage: ');
for i = 2:length(mscores)
    fprintf(fid, '<TD>%.2f (%.2f)</TD>\n', mscores(i), mean(conf.countedtime(i-1,:)));
    fprintf(' : %.2f dB', mscores(i));    
end;
fprintf(fid, '</TR>\n');
fprintf('\n');
fprintf(fid, '</TABLE>\n');
if isfield(conf, 'etc')
    fprintf(fid, '<H2>%s</H2>\n', conf.etc);
else
    fprintf(fid, '<H1>Simulation parameters</H1>\n<TABLE border="1">\n');
    fprintf(fid, sprintf('<TR><TD>Scaling factor<TD>x%d</TR>\n', conf.scale));
    fprintf(fid, sprintf('<TR><TD>High-res. patch size<TD>%d x %d</TR>\n', ...
        conf.window(1) * conf.scale, conf.window(2) * conf.scale));
    fprintf(fid, sprintf('<TR><TD>Feature upsampling factor<TD>%d\n', ...
        conf.upsample_factor));
    fprintf(fid, sprintf('<TR><TD>Feature dim. (original)<TD>%d</TR>\n', ...
        size(conf.V_pca, 1)));
    fprintf(fid, sprintf('<TR><TD>Feature dim. (reduced)<TD>%d</TR>\n', ...
        size(conf.V_pca, 2)));
    fprintf(fid, sprintf('<TR><TD>Dictionary size<TD>%d</TR>\n', ...
        conf.ksvd_conf.dictsize));
    fprintf(fid, sprintf('<TR><TD>Dictionary maximal sparsity<TD>%d</TR>\n', ...
        conf.ksvd_conf.Tdata));
    fprintf(fid, sprintf('<TR><TD>Dictionary iterations<TD>%d</TR>\n', ...
        conf.ksvd_conf.iternum));
    fprintf(fid, sprintf('<TR><TD>Duration<TD>%.1f seconds</TR>\n', ...
        conf.duration));
    fprintf(fid, sprintf('<TR><TD># of images<TD>%d</TR>\n', ...
        numel(conf.filenames)));
    fprintf(fid, sprintf('<TR><TD>Interpolation Kernel<TD>%s</TR>\n', ...
        conf.interpolate_kernel));
    fprintf(fid, '</TABLE>\n');
end

fprintf(fid, '%s\n', datestr(now));
fprintf(fid, '</BODY></HTML>\n');
fclose(fid);
fprintf('\n');

function s = esc(s)
s = strrep(s, ' ', '%20');
