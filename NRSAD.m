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
audioFile = ['s0201a_16k_nr_wiener.wav'];truthFile = ['s0201a.m'];
% audioPath = 'C:\Users\Huang\Research\audio\MatlabWiener\versameAudio\';
% truthPath = 'C:\Users\Huang\Research\versameFolder\';
% audioFile = ['YAT001_16k_nr_wiener.wav'];
% truthFile = ['YAT001.m'];

testFile = fullfile(audioPath, audioFile);
[yTest,FsTest] = audioread(testFile);
segments = segment(yTest, FsTest, timeDur);

fullbandE = energy(segments, 'fullband', FsTest);
highbandE = energy(segments, 'highband', FsTest);

%% visualize
labelFont = 8;
titleFont = 12;

figure
ax(1) = subplot(3,1,1);
plot([1:length(yTest)]/FsTest, yTest)
ylabel('Audio amplitude', 'fontsize', labelFont)

ax(2) = subplot(3,1,2);
plot([1:length(fullbandE)]/1000*timeDur, fullbandE);
ylabel('full band energy', 'fontsize', labelFont)

ax(3) = subplot(3,1,3);
plot([1:length(highbandE)]/1000*timeDur, highbandE);
ylabel('high band energy', 'fontsize', labelFont)

linkaxes(ax, 'x')