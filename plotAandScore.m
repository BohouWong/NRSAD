function A = plotAandScore(TF, timeDur, truth)

score = zeros(1,1000);
for A = 1:1000
    th = thresh(TF(1:15), A);
    [index, ~] = reliableIslands(TF, th, timeDur);
    [tpr, fpr, ~] = roc(truth(1:length(TF)), index);
    score(A) = tpr(2) - fpr(2);
end
% figure;
% plot(1:1000, score);
[~,A] = max(score);

end