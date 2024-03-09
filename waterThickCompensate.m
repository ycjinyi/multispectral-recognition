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
path = "2024012320";
upFile = strcat(path, "\", path, "up.xlsx");
downFile = strcat(path, "\", path, "down.xlsx");
upData = readmatrix(upFile);
downData = readmatrix(downFile);
upData = upData(1: 187, :);
downData = downData(1: 146, :);

% %展示数据
% figure;
% plot(upData(:, 5)); hold on;
% plot(upData(:, 3));
% figure;
% plot(downData(:, 5)); hold on;
% plot(downData(:, 3));

%区分前坡和后坡数据
upLim = 32;
upFront = upData(1: upLim, :);
upBack = upData(upLim + 1: end, :);
downLim = 113;
downFront  = downData(downLim: end, :);
downBack = downData(1: downLim - 1, :);

%将前坡数据和后坡数据依次按照电压值排序, 以电压值作为基准
[~, idx] = sort(upFront(:, 5));
upFront = upFront(idx, :);
[~, idx] = sort(downFront(:, 5));
downFront = downFront(idx, :);
[~, idx] = sort(upBack(:, 5), 'descend');
upBack = upBack(idx, :);
[~, idx] = sort(downBack(:, 5), 'descend');
downBack = downBack(idx, :);

%拟合下降过程中的前坡数据曲线
x = downFront(:, 5);
y = downFront(:, 3);
[fitresult, ~] = cruvFit(x, y, "smoothingspline", 0.97);
upFrontPredict = fitresult(upFront(:, 5));
% figure;
% plot(upFrontPredict); hold on;
% plot(upFront(:, 3));

%拟合下降过程中的后坡数据曲线
x = downBack(:, 5);
y = downBack(:, 3);
[fitresult, ~] = cruvFit(x, y, "smoothingspline", 0.96);
upBackPredict = fitresult(upBack(:, 5));
% figure;
% plot(upBackPredict); hold on;
% plot(upBack(:, 3));

%抽水计算的厚度
upPredict = [upFrontPredict; upBackPredict];
%边缘计算的厚度
upMeasurement = [upFront(:, 3); upBack(:, 3)];

% figure;
% plot(upMeasurement, upPredict, Marker="*", MarkerSize=2, LineStyle="none");
% grid on;

%分段拟合
lim1 = 21;
lim2 = 53;
x1 = upMeasurement(1: lim1 - 1, :);
y1 = upPredict(1: lim1 - 1, :);
x2 = upMeasurement(lim1: lim2 - 1, :);
y2 = upPredict(lim1: lim2 - 1, :);
x3 = upMeasurement(lim2: end, :);
y3 = upPredict(lim2: end, :);

%先对第一段和第三段进行线性拟合，然后增加点数提高权重
[fitresult, ~] = cruvFit(x1, y1, "poly1");
nx1 = 0.96: 0.05: 1.46;
nx1 = nx1';
ny1 = fitresult(nx1);
[fitresult, ~] = cruvFit(x3, y3, "poly1");
nx2 = 2: 0.05: 7.5;
nx2 = nx2';
ny2 = fitresult(nx2);

%重新组合数据进行拟合
xData = [nx1; x2; nx2];
yData = [ny1; y2; ny2];
yData = yData - xData;
[xData, idx] = sort(xData);
yData = yData(idx);
yData = medfilt1(yData, 9);

xData = [xData(1: 10, :); xData(22: end, :)];
yData = [yData(1: 10, :); yData(22: end, :)];

% % yData = yData + xData;

%进行平滑样条拟合
[fitresult, ~] = cruvFit(xData, yData, "smoothingspline", 0.9997);
px = 1: 0.05: 7.5;
px = px';
py = fitresult(px);
figure;
plot(px, py, Marker="*", MarkerSize=2, LineStyle="none");
grid on;
%重新拟合,去除逆序点
[fitresult, ~] = cruvFit(px, py, "smoothingspline", 0.99998);
py = fitresult(px);
figure;
plot(px, py + px); hold on;
plot(px, px); hold on;
plot(px, py); 
xlabel("厚度(mm)");
ylabel("厚度(mm)");
legend("计算值", "边缘测量值", "补偿值");
grid on;

save waterThickCompensate.mat fitresult











