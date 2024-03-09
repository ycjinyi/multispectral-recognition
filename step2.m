clc;
clear;
close all;

%波段数目
pNum = 4;
%接收管数目
rNum = 3;
%读取目标xlsx文件
path = "2024012803";
file = strcat(path, "\pdata.xlsx");
d = readmatrix(file);


% %范围调整
% d = d(11: 493, :);

%精度调整
d(:, 3: end) = d(:, 3: end) / 15;

%对接收光纤1的890, 1405, 1465, 1575nm波段进行滤波
b = 3;
d(:, 3) = medfilt1(d(:, 3), b + 2);
d(:, 4) = medfilt1(d(:, 4), b + 6);
d(:, 5) = medfilt1(d(:, 5), b + 4);
d(:, 6) = medfilt1(d(:, 6), b + 2);

%对接收光纤2的890, 1405, 1465, 1575nm波段进行滤波
d(:, 7) = medfilt1(d(:, 7), 5);
d(:, 8) = medfilt1(d(:, 8), 7);
d(:, 9) = medfilt1(d(:, 9), 7);
d(:, 10) = medfilt1(d(:, 10), 7);

% %对接收光纤3的890, 1405, 1465, 1575nm波段进行滤波
% d(:, 11) = medfilt1(d(:, 11), 67);
% d(:, 12) = medfilt1(d(:, 12), 67);
% d(:, 13) = medfilt1(d(:, 13), 67);
% d(:, 14) = medfilt1(d(:, 14), 67);

%统计最大值、最小值、均值
minDdata = min(d);

%作图展示
for i = 1: rNum
    figure(i);
    for j = 1: pNum
        colum = 3 + (i - 1) * pNum + (j - 1);
        %plot(1:1:size(d, 1), d(:, colum) - minDdata(:, colum) + 0.1); hold on;
        plot(1:1:size(d, 1), d(:, colum)); hold on;
        %plot(rb: 1: re, d(rb: re, colum)); hold on;
    end
    legend("890", "1405", "1465", "1575");
    ylabel("响应");
    xlabel("时间");
    ylim([0.01, 20])
    set(gca, "YScale", "log");
    grid on;
end