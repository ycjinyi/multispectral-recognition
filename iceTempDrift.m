clc;
close all;
clear;

%波段数目
pNum = 4;
%接收管数目
rNum = 3;
%读取目标文件夹下的所有数据
path = "结冰温漂\";
files = dir(fullfile(path,"*.xlsx"));
fileNames = {files.name};
file = fullfile(path, cell2mat(fileNames(1, 1)));
d = readmatrix(file);
%创建保存数据的矩阵[a, b, c] => a是厚度, b是温度, c是响应
base = 5;
tdMatrix = zeros(size(fileNames, 2), size(d, 1), size(d, 2) - base + 1);
thick = ones(size(fileNames, 2),  1);
temp = d(:, 4);
tempNum = size(temp, 1);
CG = ColorGenerator();
[colorTable, tempStr] = CG.generate(temp');
%保存数据
for i = 1: size(fileNames, 2)
  file = fullfile(path, cell2mat(fileNames(1, i)));
  d = readmatrix(file);
  thick(i, 1) = d(1, 2);
  tdMatrix(i, :,  :) = d(:, base: end);
end
[~, index] = sort(thick);
%需要展示的温度点
tp = 9: 4: tempNum;
tempStr = tempStr(1, tp);
%作图展示不同温度下的响应随厚度变化的情况
x = thick(index);

%滤波和拟合的参数
fitParam = ...
[0.78, 0.9, 0.9, 0.7;
0.55, 0.7, 0.8, 0.7; 
0.9, 0.7, 0.7, 0.6];

filtParam = ...
[7, 7, 7, 3; 
3, 3, 3, 7; 
3, 9, 9, 9];

%保存不同厚度、温度点下理想的电压值和实际的电压值之差
%[a, b, c] a是不同厚度点, b是不同的温度值, c是理想和实际电压值之差
diffMatrix = zeros(size(thick, 1), size(tp, 2), size(tdMatrix, 3));

for i = 1: rNum
    for j = 1: pNum
        colum = (i - 1) * pNum + j;
        figure;
        for k = 1: size(tp, 2)
        % for k = 1: 1
            y = tdMatrix(:, tp(1, k), colum);
            y1 = y(index);
            % plot(x, y1, 'Color', ...
            %     [colorTable(tp(1, k), :), 0.6], ...
            %     Marker='x', MarkerSize=3, LineStyle='none'); hold on;
            y2 = medfilt1(y1, filtParam(i, j));
            [fitresult, gof] = cruvFit(x, y2, 'smoothingspline', fitParam(i, j));
            plot(x, fitresult(x), 'Color', ...
                [colorTable(tp(1, k), :), 0.6], LineWidth=0.5); hold on;
            diff = fitresult(x) - y1;
            diffMatrix(:, k, colum) = diff;
        end
        legend(tempStr);
        ylabel("响应");
        xlabel("冰厚");
        %ylim([0.01, 20])
        %set(gca, "YScale", "log");
        grid on;
    end
end
t = temp(tp);
% save iceDrift.mat diffMatrix fitParam filtParam x t