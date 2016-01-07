function visualize(index, FsTest, timeDur, yTest, indexRefine, ySpIndex, thezr, TF, EZR, truth, EZRCurve)

labelFont = 8;
titleFont = 12;

ySpIndexReliable = repmat([index,0], FsTest/1000*timeDur, 1);
ySpIndexReliable = reshape(ySpIndexReliable, 1, []);
ySpIndexReliable = ySpIndexReliable(1:length(yTest));

ySpIndexRefine = repmat([indexRefine,0], FsTest/1000*timeDur, 1);
ySpIndexRefine = reshape(ySpIndexRefine, 1, []);
ySpIndexRefine = ySpIndexRefine(1:length(yTest));

figure
ax(1) = subplot(4,1,1);
plot([1:length(yTest)]/FsTest, yTest)
hold on;
x = [1:length(yTest)]/FsTest;
plot(x(ySpIndex == 1), yTest(ySpIndex == 1), '.r');
hold off;
ylabel('Audio amplitude', 'fontsize', labelFont)

ax(2) = subplot(4,1,3);
plot([1:length(yTest)]/FsTest, yTest)
hold on;
x = [1:length(yTest)]/FsTest;
plot(x(ySpIndexReliable == 1), yTest(ySpIndexReliable == 1), '.g');
hold off;
ylabel('Audio amplitude, reliable', 'fontsize', labelFont)

% ax(3) = subplot(4,1,3);
% plot([1:length(TF)]/1000*timeDur, TF);
% hold on;
% plot([1:length(TF)]/1000*timeDur, th*ones(1, length(TF)), 'r');
% hold off;
% ylabel('time frequency parameter', 'fontsize', labelFont)

ax(3) = subplot(4,1,4);
plot([1:length(yTest)]/FsTest, yTest)
hold on;
x = [1:length(yTest)]/FsTest;
plot(x(ySpIndexRefine == 1), yTest(ySpIndexRefine == 1), '.g');
hold off;
ylabel('Audio amplitude, refine', 'fontsize', labelFont)

ax(4) = subplot(4,1,2);
plot([1:length(TF)]/1000*timeDur, EZR, '.');
ylabel('EZR', 'fontsize', labelFont)
%axis([-inf, inf, 0, 0.01]);
hold on;
x = [1:length(TF)]/1000*timeDur;
plot(x(truth == 1), EZR(truth == 1), 'g.');
plot([1:length(TF)]/1000*timeDur, thezr*ones(1,length(TF)), 'r');
%plot([1:length(TF)]/1000*timeDur, EZRCurve, 'y');
hold off;

linkaxes(ax, 'x')

end