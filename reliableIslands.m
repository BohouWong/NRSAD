function [index, SP] = reliableIslands(TF, th, timeDur)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find reliable islands based on TF (time frequency parameters)
% start point is detected when TF is first over th for at least 5 frames
% end point is detected when TF is below th for at least 6 frames
% input:
%   TF:         TF data of all frames, 1*N vector
%   th:         threshold
%   timeDur:    duration of each frame in miliseconds
% output:
%   index:     	1*N vector for 1 indicates the frame belongs to SP and 0
%               otherwies
%   SP:         a 2 columns matrix recording the start and end points of SP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index = TF > th;

%% decoding sequence
findSp = 1;
SP = [];startP = 0; endP = 0;
for i = 1:length(index)
%     if index(i) == 1
%         firstZero = find(~index(i:end), 1) + i - 1;
%         if isempty(firstZero)
%             firstZero = length(index);
%         end
%         if sum(index(i:firstZero)) >= 5
%             i = firstZero;
%         else
%             index(i:firstZero) = 0;
%             i = firstZero;
%         end
%     end
    if findSp
        if index(i) == 1
            firstZero = find(~index(i:end), 1) + i - 1;
            if isempty(firstZero)
                firstZero = length(index);
            end
            if sum(index(i:firstZero)) >= 5
                findSp = 0;
                startP = (i-1)*timeDur/1000 + 1/2*timeDur/1000;
            else
                index(i:firstZero) = 0;
            end
        end
    else
        if index(i) == 0
            firstZero = find(index(i:end), 1) + i - 1;
            if isempty(firstZero)
                firstZero = length(index);
            end
            if sum(~index(i:firstZero)) >= 6
                findSp = 1;
                endP = (i-1)*timeDur/1000 + 1/2*timeDur/1000;
                SP = [SP; [startP, endP]];
            else
                index(i:firstZero) = 1;
            end
        end
    end
end

end
