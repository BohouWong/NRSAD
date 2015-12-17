function z = zerocrossing(segments, instr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute ZCR for each frame
% Can either be ZCR or EZR
% input:
%   segments:   audio data frames, M*N matrix
%   instr:      'ZCR' or 'EZR'
% output:
%   e:          energy of each frame, 1*N vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

z = zeros(1, size(segments, 2));
if strcmp(instr, 'ZCR')
    for i = 1:size(segments, 2)
        thresh = 0; 
        N = length(segments(:,i));
        zc = (segments(:,i) >= thresh) - (segments(:,i) < thresh);
        z(i) = sum((zc(1:N-1) - zc(2:N)) ~= 0)/N;
    end
elseif strcmp(instr, 'EZR')
    for i = 1:size(segments, 2)
        thresh = 0; 
        N = length(segments(:,i));
        zc = (segments(:,i) >= thresh) - (segments(:,i) < thresh);
        rate = sum((zc(1:N-1) - zc(2:N)) ~= 0)/N;
        if rate == 0
            rate = min(z(1:i-1))/10;
        end
        z(i) = sum(segments(:,i).^2)/rate;
    end
end

end