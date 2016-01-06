function P = trainP(EZR, timeDur, index, truth, TF)

score = zeros(1,length(50:90));
percen = 50:90;
for i = 1:length(percen)
    thezr = prctile(EZR, percen(i));
    [indexRefine, ~] = refine(EZR, thezr, timeDur, index);
    [tpr, fpr, ~] = roc(truth(1:length(TF)), indexRefine);
    score(i) = tpr(2) - fpr(2);
end

%plot(1:length(percen), score);
[~, P] = max(score);
P = P + 50;

end