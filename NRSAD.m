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

fullbandE = energy(segments, 'fullband', FsTest);
highbandE = energy(segments, 'highband', FsTest);

%% compute TF
fullbandE = medfilt1(fullbandE, 50);
highbandE = medfilt1(highbandE, 50);
fullbandE = fullbandE/max(fullbandE);
highbandE = highbandE/max(highbandE);
TF = fullbandE + highbandE;

%% compute threshold
th = thresh(TF(1:15), 200);

%% find reliable islands
[index, SP] = reliableIslands(TF, th, timeDur);

%% compute EZR and threshold
EZR = zerocrossing(segments, 'EZR');
EZR = medfilt1(EZR, 500);
EZR = EZR/max(EZR);
thezr = prctile(EZR, 10)*1500;

%% refine reliable islands
[indexRefine, ~] = refine(EZR, thezr, timeDur, index);

%% visualize
% labelFont = 8;
% titleFont = 12;
% 
% figure
% ax(1) = subplot(3,1,1);
% plot([1:length(yTest)]/FsTest, yTest)
% ylabel('Audio amplitude', 'fontsize', labelFont)
% 
% % ax(2) = subplot(4,1,2);
% % plot([1:length(fullbandE)]/1000*timeDur, fullbandE);
% % ylabel('full band energy', 'fontsize', labelFont)
% % 
% % ax(3) = subplot(4,1,3);
% % plot([1:length(highbandE)]/1000*timeDur, highbandE);
% % ylabel('high band energy', 'fontsize', labelFont)
% 
% ax(2) = subplot(3,1,2);
% plot([1:length(TF)]/1000*timeDur, TF);
% hold on;
% plot([1:length(TF)]/1000*timeDur, th*ones(1, length(TF)), 'r');
% hold off;
% ylabel('time frequency parameter', 'fontsize', labelFont)
% 
% ax(3) = subplot(3,1,3);
% plot([1:length(TF)]/1000*timeDur, EZR);
% ylabel('EZR', 'fontsize', labelFont)
% hold on;
% plot([1:length(TF)]/1000*timeDur, thezr*ones(1, length(TF)), 'r');
% hold off;
% 
% linkaxes(ax, 'x')

%% compare performance
% get ground truth
run(fullfile(truthPath, truthFile));
truthLen = max(round(SPEECH(size(SPEECH,1), 2) * 1000/timeDur), round(length(yTest)/FsTest*1000/timeDur));
truth = zeros(1, truthLen);
for j = 1:size(SPEECH,1)
    for k = max(round(SPEECH(j,1)*1000/timeDur), 1):round(SPEECH(j,2)*1000/timeDur)
        truth(k) = 1;
    end
end
figure;
[tpr, fpr, ~] = roc(truth(1:length(TF)), TF/2);
plot(fpr, tpr, 'LineWidth', 4);
hold on; 
plot(fpr, fpr);
xlabel('False Positive Rate');ylabel('True Positive Rate');
[tpr, fpr, ~] = roc(truth(1:length(TF)), index);
plot(fpr(2), tpr(2), 'r*', 'LineWidth', 2);
[tpr, fpr, ~] = roc(truth(1:length(TF)), indexRefine);
plot(fpr(2), tpr(2), 'g*', 'LineWidth', 2);
hold off;