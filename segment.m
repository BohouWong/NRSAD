function segments = segment(yTest, Fs, timeDur)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Segment the signal data into a matrix
% each column has #timeDur*Fs samples
% input:
%   yTest:   audio signal data generated by audioread
%   Fs:      audio signal frequency
%   timeDur: time duration of each frame, in miliseconds
% output:
%   segments:the output matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Miliseconds = length(yTest)/Fs*1000;
segments = yTest(1:(Miliseconds-mod(Miliseconds, timeDur))*Fs/1000);
segments = reshape(segments, timeDur/1000*Fs, []);

end