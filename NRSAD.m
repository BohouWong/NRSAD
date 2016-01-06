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
audioFile = ['s0201a_16k_nr_wiener.wav'];
truthFile = ['s0201a.m'];

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
A = plotAandScore(TF, timeDur, truth);

%% compute threshold
th = thresh(TF(1:15), A);

%% find reliable islands
[index, SP] = reliableIslands(TF, th, timeDur);

%% compute EZR and threshold
EZR = zerocrossing(segments, 'EZR');
EZR = medfilt1(EZR, 50);
EZR = EZR/max(EZR);
P = trainP(EZR, timeDur, index, truth, TF);
thezr = prctile(EZR, P);

%% refine reliable islands
[indexRefine, ~] = refine(EZR, thezr, timeDur, index);

%% visualize
% labelFont = 8;
% titleFont = 12;
% 
% ySpIndexReliable = repmat([index,0], FsTest/1000*timeDur, 1);
% ySpIndexReliable = reshape(ySpIndexReliable, 1, []);
% ySpIndexReliable = ySpIndexReliable(1:length(yTest));
% 
% figure
% ax(1) = subplot(4,1,1);
% plot([1:length(yTest)]/FsTest, yTest)
% hold on;
% x = [1:length(yTest)]/FsTest;
% plot(x(ySpIndex == 1), yTest(ySpIndex == 1), '.r');
% hold off;
% ylabel('Audio amplitude', 'fontsize', labelFont)
% 
% ax(2) = subplot(4,1,2);
% plot([1:length(yTest)]/FsTest, yTest)
% hold on;
% x = [1:length(yTest)]/FsTest;
% plot(x(ySpIndexReliable == 1), yTest(ySpIndexReliable == 1), '.g');
% hold off;
% ylabel('Audio amplitude', 'fontsize', labelFont)
% 
% ax(3) = subplot(4,1,3);
% plot([1:length(TF)]/1000*timeDur, TF);
% hold on;
% plot([1:length(TF)]/1000*timeDur, th*ones(1, length(TF)), 'r');
% hold off;
% ylabel('time frequency parameter', 'fontsize', labelFont)
% 
% ax(4) = subplot(4,1,4);
% plot([1:length(TF)]/1000*timeDur, EZR);
% ylabel('EZR', 'fontsize', labelFont)
% %axis([-inf, inf, 0, 0.01]);
% hold on;
% x = [1:length(TF)]/1000*timeDur;
% plot(x(truth == 1), EZR(truth == 1), 'g.');
% plot([1:length(TF)]/1000*timeDur, thezr*ones(1,length(TF)), 'r');
% hold off;
% 
% linkaxes(ax, 'x')

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