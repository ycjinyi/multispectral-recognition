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
%保存数据
data = [];
for i = 1: size(fileNames, 2)
  file = fullfile(path, cell2mat(fileNames(1, i)));
  d = readmatrix(file);
  data = [data; mean(d)];
end

[~, index] = sort(data(:, 2));
data = data(index, :);


x = data(:, 2);
y = data(:, 5);

finalData = data;
%通过曲线拟合的方式修正数据
for i = 5: size(data, 2)
    [fitresult, gof] = cruvFit(data(:, 2), data(:, i), 'smoothingspline');
    finalData(:, i) = fitresult(data(:, 2));
end

%作图展示, 三维坐标
for i = 1: rNum
    figure;
    for j = 1: pNum
        colum = 5 + (i - 1) * pNum + (j - 1);
        plot(data(:, 2), data(:, colum)); hold on;
        plot(data(:, 2), finalData(:, colum)); hold on;
        % plot(data(:, 2), data(:, 4)); hold on;
    end
    legend("890", "890-1", "1405", "1405-1", "1465", "1465-1", "1575", "1575-1");
    % legend("890", "1405", "1465", "1575");
    % legend("1405", "1465", "1575");
    ylabel("水厚");
    xlabel("冰厚");
    zlabel("响应")
    %ylim([0.01, 20])
    %set(gca, "YScale", "log");
    grid on;
end