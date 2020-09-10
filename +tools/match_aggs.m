
% MATCH_AGGS  Attempt to match two aggregates between two Aggs structures.
% Looks for closest aggregate, limiting consideration to only 150 px.
%=========================================================================%

function [idx_a, idx_b] = match_aggs(Aggs_a, Aggs_b)

% Initialize quantities.
A = [Aggs_a.center_mass]';
B = [Aggs_b.center_mass]';

A_cc = zeros(size(A));
B_cc = zeros(size(B));
cc_b = zeros(size(B,1), 1);


% Loop through images in Aggs_a.
for ii=1:max([Aggs_a.img_id])
    
    idx_a = find([Aggs_a.img_id]==ii); % index in Aggs_a for this image
    
    idx_b0 = find(strcmp({Aggs_b.fname}, Aggs_a(idx_a(1)).fname));
    idx_b0 = Aggs_b(idx_b0(1)).img_id; % initial image index in Aggs_b
    idx_b = find([Aggs_b.img_id]==idx_b0); % index in Aggs_b for this image
    
    for jj=idx_a % loop through aggregates in Aggs_a for this image
        d = pdist2(Aggs_a(jj).center_mass', ...
            B(idx_b, :)); % calculate the distance between 2 datasets 
        d_min(jj) = min(d(:)); % find the minimum value of distance
        
        if d_min(jj)<150 % only consider if centers are close (within 150 px)
            [~, row_b] = find(d == d_min(jj));
            
            cc_b(idx_b(row_b)) = jj;
            B_cc(jj,:) = B(idx_b(row_b), :);
            A_cc(jj,:) = A(jj, :);
            
            d = pdist2(A(idx_a, :), ...
                B(idx_b(row_b), :)); % calculate the distance between 2 datasets 
            d_min2 = min(d(:)); % find the minimum value of distance
            
            % Check to make sure also the closest point in Aggs_a
            if d_min2~=d_min(jj)
                cc_b(idx_b(row_b)) = 0; % zero if not closest point in Aggs_a
            end
        end
    end
end

% Evaluate index of overlapping aggregates. 
% First column of idx_ab is index for Aggs_a. 
% Second column is index for Aggs_b.
idx_ab = [cc_b, (1:length(Aggs_b))'];
idx_ab = idx_ab(cc_b~=0, :);

if nargout>1
    idx_a = idx_ab(:,1);
    idx_b = idx_ab(:,2);
else
    idx_a = idx_ab;
end


end

