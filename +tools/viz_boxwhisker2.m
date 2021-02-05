
% VIX_BOXWHISKER2  Generate box-whisker plot of primary particle sizes. 
%  
%  AUTHOR: Timothy Sipkens, 2021-01-27

function [h] = viz_boxwhisker2(field, varargin)

% Use PCM by default.
if ~iscell(field); field = {field}; end
if isempty(field{1}); field = {'pcm1'}; end


dp_vec = [];
group = {};
for jj=1:length(field)
    dp0 = [varargin{1}.(['dp_', field{jj}])];
    
    for ii=2:length(varargin)
        [ia, ib] = tools.match_aggs(varargin{1}, varargin{ii});

        ab = [varargin{ii}.(['dp_', field{jj}])];

        dp_vec = [dp_vec, ...
            log10((ab(ib) ./ dp0(ia)))];
        group = [group; ...
            repmat({[field{jj}, '-', ...
            num2str(ii - 1)]}, ...
            [length(ib), 1])];
    end
end

group = group';
dp_vec = dp_vec';


boxplot(dp_vec, group, 'width', 0.5);


% Overlay scatter
for jj=1:length(field)
    dp0 = [varargin{1}.(['dp_', field{jj}])];
    for ii=2:length(varargin)
        [ia, ib] = tools.match_aggs(varargin{1}, varargin{ii});

        ab = [varargin{ii}.(['dp_', field{jj}])];

        dp0_min = log10(min(dp0(ia)));
        dp0_max = log10(max(dp0(ia)));
        jitter = ones([size(ab, 1), 1]) .* ((ii - 1) + (length(varargin) - 1) .* (jj - 1)) + ...
            0.4 .* ((log10(dp0(ia)') - dp0_min) ./ (dp0_max - dp0_min) - 0.5);

        hold on;
        plot(jitter, log10(ab(ib) ./ dp0(ia)), 'k.');
        hold off;
    end
end

hold on;
plot(1.5, ...
    log10([1/16, 1/8, 1/4, 1/2, 1, 2, 4, 8, 16]), 's');
hold off;

ylabel('Aggsii / Aggs1 (Aggs1 generally = slider)');

if nargout==0; clear h; end

end

