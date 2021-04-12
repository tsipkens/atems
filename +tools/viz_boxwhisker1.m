
% VIX_BOXWHISKER1  Generate box-whisker plot of primary particle sizes. 
%  
%  AUTHOR: Timothy Sipkens, 2021-01-27

function [h] = viz_boxwhisker1(varargin)

dp_vec = [];
group = [];
for ii=1:length(varargin)
    Aggs = varargin{ii};

    dp0 = [Aggs.dp_edm];

    t0 = log10([[Aggs.dp_pcm1] ./ dp0; ...
        [Aggs.dp_edm_ws] ./ dp0; ...
        [Aggs.dp_kook] ./ dp0])';
    dp_vec = [dp_vec; t0(:)];
    
    t0 = repmat({['pcm1-', num2str(ii)], ...
        ['edm_ws-', num2str(ii)], ...
        ['kook-', num2str(ii)]}, ...
        [size(t0, 1), 1]);
    group = [group; t0(:)];
end


boxplot(dp_vec, group, 'width', 0.5,'symbol', '');


% Overlay scatter
for ii=1:length(varargin)
    Aggs = varargin{ii};

    dp0 = [Aggs.dp_edm];

    dp_vec = log10([[Aggs.dp_pcm1] ./ dp0; ...
        [Aggs.dp_edm_ws] ./ dp0; ...
        [Aggs.dp_kook] ./ dp0])';
    
    f_out = ~isoutlier(log10(dp0));
    dp0_min = log10(min(dp0(f_out)));
    dp0_max = log10(max(dp0(f_out)));
    jitter = (ii - 1) .* 3 + ...
        ones([size(dp_vec, 1), 1]) * (1:size(dp_vec, 2)) + ...
        0.4 .* ((log10(dp0') - dp0_min) ./ (dp0_max - dp0_min) - 0.5);
    hold on;
    plot(jitter, dp_vec, 'k.');
    hold off;
end

hold on;
plot(1.5, ...
    log10([1/16, 1/8, 1/4, 1/2, 1, 2, 4, 8, 16]), 's');
hold off;

ylabel('dp / dp,edm-sbs');

if nargout==0; clear h; end

end

