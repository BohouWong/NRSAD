function [index, SP] = refine(EZR, thezr, timeDur, index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find reliable islands based on TF (time frequency parameters)
% start point is detected when TF is first over th for at least 5 frames
% end point is detected when TF is below th for at least 6 frames
% input:
%   EZR:        TF data of all frames, 1*N vector
%   thezr:      threshold
%   timeDur:    duration of each frame in miliseconds
%   index:      index of reliable islands
% output:
%   index:     	1*N vector for 1 indicates the frame belongs to SP and 0
%               otherwies
%   SP:         a 2 columns matrix recording the start and end points of SP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SP = [];
ezrindex = EZR > thezr;
searchRange = 6;

% if the EZR is below thezr for a certain percentage of a reliable island, 
% then delete this part
% for i = 1:length(index)
%     if (index(i) == 1) && (index(max(i-1, 1)) == 0)  
%         startIndex = i;
%     elseif (index(i) == 1) && (index(min(i+1, end)) == 0)
%         endIndex = i;
%         percen = sum(ezrindex(startIndex:endIndex))/length(startIndex:endIndex);
%         if(percen < 0.3)
%             %output = startIndex:endIndex
%             index(startIndex:endIndex) = 0;
%         end
%     end
% end

% refine start and end points
for i = 1:length(index)
    if (index(i) == 1) && (index(min(i+1, end)) == 0)
        % endpoint
        if ezrindex(i) == 0
            for j = i:-1:i-searchRange
                if ezrindex(j) == 1
                    index((j+1):i) = 0;
                    break;
                end
            end
        else
            for j = i:i+searchRange
                if ezrindex(j) == 0
                    index(i:(j-1)) = 1;
                    break;
                end
            end
        end
    elseif (index(i) == 1) && (index(max(i-1, 1)) == 0)
        % start point
        if ezrindex(i) == 0
            for j = i:i+searchRange
                if ezrindex(j) == 1
                    index(i:(j-1)) = 0;
                    break;
                end
            end
        else
            for j = i:-1:i-searchRange
                if ezrindex(j) == 0
                    index((j+1):i) = 1;
                    break;
                end
            end
        end
    end
end

end