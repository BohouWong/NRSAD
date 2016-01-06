function A = trainA(TF, timeDur, truth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find optimal value of A in consideration of TP and FP
% Start point is set at 200
% May not be the global optimal value
% input:
%   TF:         TF data of all frames, 1*N vector
%   timeDur:    duration of each frame in miliseconds
%   truth:      ground truth
% output:
%   A:          optimal value of A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = 300;
delta = 1;
step = 2;
e = 1e-5;
noise = TF(1:15);

while 1
    th1 = thresh(noise, A);
    th2 = thresh(noise, A+delta);
    [index1, ~] = reliableIslands(TF, th1, timeDur);
    [index2, ~] = reliableIslands(TF, th2, timeDur);
    [tpr1, fpr1, ~] = roc(truth(1:length(TF)), index1);
    [tpr2, fpr2, ~] = roc(truth(1:length(TF)), index2);
    score1 = tpr1(2) - fpr1(2);
    score2 = tpr2(2) - fpr2(2);
    dif = score1 - score2;
    if abs(score1-score2) < e
        break;
    else
        A = A - min(step*dif*1e5, 10);
    end
end