function e = energy(segments, instr, Fs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute energy for each frame
% Can either be fullaband or highband energy
% input:
%   segments:   audio data frames, M*N matrix
%   instr:      'fullband' or 'highband'
% output:
%   e:          energy of each frame, 1*N vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

e = zeros(1, size(segments, 2));
if strcmp(instr, 'fullband')
    for i = 1:size(segments, 2)
        %e(i) = 10*log10(sum(segments(:,i).^2));
        e(i) = sum(segments(:,i).^2);
    end
elseif strcmp(instr, 'highband')
    for i = 1:size(segments,2)
        e(i) = bandpower(segments(:,i), Fs, [2000, 4000]);
        %e(i) = bandpower(segments(:,i));
    end
end

end