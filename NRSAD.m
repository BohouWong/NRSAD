%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A Noise Robust SAD (I hope so)
% read sigal from audio file, segment into 10ms per segment
% use energy feature (fullband & highband energy) to find reliable islands
% use EZR to refine start & end points

% 12/16/2015: start with test on buckeye file, plot the feature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear;
timeDur = 10;

%% read audio and segment into frames
audioPath = 'C:\Users\Huang\Research\audio\MatlabWiener\';
truthPath = 'C:\Users\Huang\Research\buckeyeFolder\';
audioFile = ['s0102a_16k_nr_wiener.wav'];
truthFile = ['s0102a.m'];

% audioPath = 'C:\Users\Huang\Research\audio\MatlabWiener\versameAudio\';
% truthPath = 'C:\Users\Huang\Research\versameFolder\';
% audioFile = ['YAT001_16k_nr_wiener.wav'];
% truthFile = ['YAT001.m'];

testFile = fullfile(audioPath, audioFile);
[yTest,FsTest] = audioread(testFile);
segments = segment(yTest, FsTest, timeDur);

% get ground truth
run(fullfile(truthPath, truthFile));
truthLen = max(round(SPEECH(size(SPEECH,1), 2) * 1000/timeDur), round(length(yTest)/FsTest*1000/timeDur));
truth = zeros(1, truthLen);
for j = 1:size(SPEECH,1)
    for k = max(round(SPEECH(j,1)*1000/timeDur), 1):round(SPEECH(j,2)*1000/timeDur)
        truth(k) = 1;
    end
end
ySpIndex = repmat(truth, FsTest/1000*timeDur, 1);
ySpIndex = reshape(ySpIndex, 1, []);
if length(yTest) > length(ySpIndex)
    ySpIndex = [ySpIndex, zeros(1,length(yTest)-length(ySpIndex))];
else
    ySpIndex = ySpIndex(1:length(yTest));
end

fullbandE = energy(segments, 'fullband', FsTest);
highbandE = energy(segments, 'highband', FsTest);

%% compute TF
fullbandE = medfilt1(fullbandE, 50);
highbandE = medfilt1(highbandE, 50);
fullbandE = fullbandE/max(fullbandE);
highbandE = highbandE/max(highbandE);
TF = fullbandE + highbandE;

%% find optimal A
%A = plotAandScore(TF, timeDur, truth);

%% compute threshold
th = thresh(TF(1:15), 100);

%% find reliable islands
[index, ~] = reliableIslands(TF, th, timeDur);

%% get new parameter th
TFnew = TF(index == 0);
TFnew = TFnew(TFnew > prctile(TFnew, 50));
TFnew = TFnew(TFnew < prctile(TFnew, 90));
th = thresh(TFnew, 0.75);
[index, SP] = reliableIslands(TF, th, timeDur);

%% compute EZR and threshold
EZR = zerocrossing(segments, 'ZCR', th);
%EZR = medfilt1(EZR, 50);
%EZR = EZR/max(EZR);

% EZRCurve = medfilt1(EZR, 100);
% EZRCurve = EZRCurve/max(EZRCurve);
P = trainP(EZR, timeDur, index, truth, TF);
thezr = prctile(EZR, P);


%% refine reliable islands
[indexRefine, ~] = refine(EZR, thezr, timeDur, index);

%% compare performance
figure;
[tpr, fpr, ~] = roc(truth(1:length(TF)), TF/2);
plot(fpr, tpr, 'LineWidth', 4);
hold on; 
plot(fpr, fpr);
xlabel('False Positive Rate');ylabel('True Positive Rate');
[tpr, fpr, ~] = roc(truth(1:length(TF)), index);
plot(fpr(2), tpr(2), 'r*', 'LineWidth', 2);
score1 = tpr(2) - fpr(2)
[tpr, fpr, ~] = roc(truth(1:length(TF)), indexRefine);
score2 = tpr(2) - fpr(2)
plot(fpr(2), tpr(2), 'g*', 'LineWidth', 2);
hold off;