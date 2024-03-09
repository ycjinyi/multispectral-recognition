clc;
clear;
close all;

%首先分别读取加水和抽水过程中的数据
%--------------------------------光电数据处理-------------------------------
%波段数目
pNum = 4;
%接收管数目
rNum = 3;
%读取目标xlsx文件
path = "2024011711";
upFile = strcat(path, "\", path, "up.xlsx");
downFile = strcat(path, "\", path, "down.xlsx");
upData = readmatrix(upFile);
downData = readmatrix(downFile);
% upData = upData(1: 187, :);
% downData = downData(1: 146, :);

lambda = 5;

% %展示数据
figure;
plot(upData(:, lambda)); hold on;
plot(upData(:, 3));
figure;
plot(downData(:, lambda)); hold on;
plot(downData(:, 3));

%数据
upFront = upData;
downFront  = downData;


%将数据依次按照电压值排序, 以电压值作为基准
[~, idx] = sort(upFront(:, lambda));
upFront = upFront(idx, :);
[~, idx] = sort(downFront(:, lambda));
downFront = downFront(idx, :);


%拟合下降过程中的数据曲线
x = downFront(:, lambda);
y = downFront(:, 3);
[fitresult, ~] = cruvFit(x, y, "smoothingspline", 0.999999);
%需要将预测的范围指定在拟合的电压范围内
maxV = max(x);
minV = min(x);
idx = find(upFront(:, lambda) >= minV & upFront(:, lambda) <= maxV);
nx = upFront(idx, lambda);
upFrontPredict = fitresult(nx);
figure;
plot(upFrontPredict); hold on;
plot(nx);


%抽水计算的厚度
upPredict = upFrontPredict;
%边缘计算的厚度
upMeasurement = upFront(idx, 3);

figure;
plot(upMeasurement, upPredict, Marker="*", MarkerSize=2, LineStyle="none");
grid on;

%拟合
x1 = upMeasurement;
y1 = upPredict;

% %进行平滑样条拟合
% [fitresult, ~] = cruvFit(x1, y1, "poly6");
% px = 1: 0.05: 7;
% px = px';
% py = fitresult(px);
% figure;
% plot(px, py, Marker="*", MarkerSize=2, LineStyle="none");
% grid on;
% 
% figure;
% plot(px, py); hold on;
% plot(px, px); hold on;
% plot(px, py - px); 
% xlabel("厚度(mm)");
% ylabel("厚度(mm)");
% legend("计算值", "边缘测量值", "补偿值");
% grid on;

% save iceWaterThickCompensate.mat fitresult