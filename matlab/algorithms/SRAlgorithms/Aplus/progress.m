function handle = progress(handle, p, verbose)

if nargin < 3
    verbose = true;
end

if isempty(handle) || now > handle.next || p == 1
    N = 20;
    n = round(p * N);

    if isempty(handle)
        start = now;
    else
        start = handle.start;
    end
    
    msg = ['[' repmat('.', 1, n) repmat(' ', 1, N-n) ']'];
    msg = sprintf('(%s) %s', datestr(now - start, 'HH:MM:SS'), msg);

    if verbose
        if ~isempty(handle)
            fprintf(repmat('\b', 1, numel(msg)));        
        end
        fprintf(msg);
    end
    
    handle.start = start;
    handle.next = now + .25 / (24*60*60);
end
