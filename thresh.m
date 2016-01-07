function th = thresh(TF, A)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the threshold for determine start and end point
% TF ususally is the first 10 or 15 frames (which are considered noise)
% threshold is computed by formula:
%   (Emax - Avr)*Avr^3*A
% input:
%   TF:         TF data of first few frames
%   A:          a constant
% output:
%   th:     	threshold for determing the vowel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Emax = max(TF);
Avr = mean(TF(TF > 0));
scale = Avr/Emax;
%th = (Emax - Avr)*scale^3*A;
th = (Emax - Avr)*A;

end