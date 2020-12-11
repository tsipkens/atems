
% AGGDIFF  Compute statistics about the differences between two aggregate structures.
% Author: Timothy Sipkens, 2020-12-02
%=========================================================================%

function [out, idx_0, idx_1] = aggdiff(Aggs, Aggs0, imgs, imgs0)

if ~exist('Aggs', 'var'); Aggs = []; end
if ~exist('imgs', 'var'); imgs = {}; end


%-- Pre-format images ----------------------------------------------------%
i0 = cat(3, imgs0{:});  % concatenate images in third dimension
i0 = reshape(i0, [numel(imgs0{1}), length(imgs0)]);  % reshape, 1 col. per image

i1 = cat(3, imgs{:});  % same formatting as above
i1 = reshape(i1, [numel(imgs{1}), length(imgs)]);

% Find and flag images with no aggregates
% (generally denotes method failure). 
f_aggs = any((1:length(imgs))==[Aggs.img_id]');
out.n_diff = sum((1:length(imgs))==[Aggs.img_id]') - ...
    sum((1:length(imgs0))==[Aggs0.img_id]');

% Final formatting, vectorize. Variables appended with "b" 
% exclude images without aggregates.
i1b = i1(:, f_aggs==1); i1b = i1b(:);
i0b = i0(:, f_aggs==1); i0b = i0b(:);
i1 = i1(:); i0 = i0(:);



%-- Compute IoU (intersect-over-union) -----------------------------------%
out.IoU = sum(and(i1,i0)) ./ sum(or(i1,i0));
out.IoU_b = sum(and(i1b,i0b)) ./ sum(or(i1b,i0b));


%-- Compute confusion matrix ---------------------------------------------%
out.fp = sum(and(~i0, i1)) ./ sum(~i0) .* 100;  % false positives
out.fn = sum(and(i0, ~i1)) ./ sum(i0) .* 100;  % true negatives
out.fp_b = sum(and(~i0b, i1b)) ./ sum(~i0b) .* 100;
out.fn_b = sum(and(i0b, ~i1b)) ./ sum(i0b) .* 100;
out.accuracy = (sum(and(~i0, ~i1)) + sum(and(i0, i1))) ./ length(i0) .* 100;
out.accuracy_b = (sum(and(~i0b, ~i1b)) + sum(and(i0b, i1b))) ./ length(i0b) .* 100;


%-- Compute % difference in da -------------------------------------------%
out.da_pd = (exp(mean(log([Aggs.da]))) ./ ...
    exp(mean(log([Aggs0.da]))) - 1) .* 100;


%-- Match aggregates and compare da --------------------------------------%
[idx_0, idx_1] = tools.match_aggs(Aggs0, Aggs);  % match aggregates in arrays
out.da_diff = (1 - [Aggs0(idx_0).da] ./ [Aggs(idx_1).da]) .* 100;  % percent diff. per aggregate
out.da_m = median(out.da_diff);  % median of the percent difference
out.da_p1 = prctile(out.da_diff, 2.5);  % percentiles of percent difference
out.da_p2 = prctile(out.da_diff, 97.5);


%-- Size comparison ------------------------------------------------------%
out.sz = size(Aggs, 2);  % number of aggregates in Aggs
out.sz0 = size(Aggs0, 2);  % number of aggregates in Aggs0
out.sz_match = size(idx_0,1);  % number of aggregates with a match
out.sz_add = size(Aggs,2) - size(idx_0,1);  % aggregates in Aggs with no match
out.sz_rmv = size(Aggs0,2) - size(idx_0,1);  % aggregates in Aggs0 with no match


end


