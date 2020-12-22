
% MATCH_AGGS  Attempt to match two aggregates between two Aggs structures.
% Looks for closest aggregate, limiting consideration to only 150 px.
%=========================================================================%

function [idx_a, idx_b] = match_aggs(Aggs_a, Aggs_b)

% Copy center of mass of each aggregate locally.
A = [Aggs_a.center_mass]';
B = [Aggs_b.center_mass]';

% Initialize arrays to be filled in loop.
A_cc = zeros(size(A));
B_cc = zeros(size(B));
cc_b = zeros(size(B,1), 1);


% Loop through images in Aggs_a structure.
for ii=1:max([Aggs_a.img_id])
    
    idx_a = find([Aggs_a.img_id]==ii);  % index in Aggs_a for this image
    
    % If this image isn't available, the classifier failed. 
    % Continue to next entry in loop.
    if isempty(idx_a); continue; end
    
    % Repeat above procedure for Aggs_b.
    idx_b0 = find(strcmp({Aggs_b.fname}, Aggs_a(idx_a(1)).fname));
    if isempty(idx_b0); continue; end  % if image isn't available, i.e., classifier failed
    
    idx_b0 = Aggs_b(idx_b0(1)).img_id;  % initial image index in Aggs_b
    idx_b = find([Aggs_b.img_id]==idx_b0);  % index in Aggs_b for this image
    
    % Loop through aggregates in Aggs_a that were in this specific image.
    for jj=idx_a
        % Calculate the distance between the aggregates in the two datasets.
        d = pdist2(A(jj, :), B(idx_b, :));
        
        % Find the minimum value of distance. This corresponds to the
        % aggregate with the center of mass closest to the current
        % aggregate in Aggs_a.
        d_min = min(d(:));
        
        % If centers are within 250 pixels, check that also closest in
        % recipricol data (check also the closest aggregate to Aggs_b). 
        if d_min<250
            [~, row_b] = find(d == d_min);  % get index of match
            
            cc_b(idx_b(row_b)) = jj;
            B_cc(jj,:) = B(idx_b(row_b), :);
            A_cc(jj,:) = A(jj, :);
            
            d = pdist2(A(idx_a, :), B(idx_b(row_b), :));  % calculate the distance between two datasets 
            d_min2 = min(d(:));  % find the minimum value of distance
            
            % Check to make sure also the closest point in Aggs_a.
            if d_min2~=d_min
                cc_b(idx_b(row_b)) = 0;  % zero if not closest point in Aggs_a
            
            % Now, let's also check if the degree of overlap is logical.
            % This prevents counting small fragments close to the center of
            % the aggregate.
            else
                % Percent difference in number of pixels.
                pd_np = 1 - abs((Aggs_b(idx_b(row_b)).num_pixels - ...
                    Aggs_a(jj).num_pixels) / Aggs_a(jj).num_pixels);
                
                % Zero if not enough overlap. Note this step would
                % automatically limit the magnitude of the discrepency 
                % possible in aggregate diameter. Note the graduated
                % threshold depending on size. For smaller aggregates, a
                % slight shift in the aggregate center could cause larger
                % discrepencies, and yet still be reasonable.
                if and(pd_np < 0.3, Aggs_a(jj).num_pixels > 30000)
                    cc_b(idx_b(row_b)) = 0;
                end
                
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

