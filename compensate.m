clc;
clear;
close;

%读取目标文件夹下的所有数据
path = "结冰温漂\结冰积水空载厚度数据\";
files = dir(fullfile(path,"*.xlsx"));
fileNames = {files.name};
rMap = containers.Map("KeyType", 'double', "ValueType", 'any');

%读取数据建立映射关系
for i = 1: size(fileNames, 2)
  name = cell2mat(fileNames(1, i));
  file = fullfile(path, name);
  d = readmatrix(file);
  %直接求平均算作一个点
  r = mean(d, 1);
  %对温度值进行离散化
  r(1, 4) = floor(r(1, 4) / 0.05) * 0.05;
  rMap(str2double(name(1, 1: end - 10))) = r;
end

%目标温度值
tarTemp = -0.5;

%计算温漂偏移
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
%保存数据
for i = 1: size(fileNames, 2)
  file = fullfile(path, cell2mat(fileNames(1, i)));
  d = readmatrix(file);
  thick(i, 1) = d(1, 2);
  tdMatrix(i, :, :) = d(:, base: end);
end

%滤波和拟合的参数
fitParam = ...
[0.78, 0.9, 0.9, 0.7;
0.55, 0.7, 0.8, 0.7; 
0.9, 0.7, 0.7, 0.6];

filtParam = ...
[7, 7, 7, 3; 
3, 3, 3, 7; 
3, 9, 9, 9];

%保存需要补偿的电压值
dMap = containers.Map("KeyType", 'double', "ValueType", 'any');

[x, index] = sort(thick);
%先遍历key集合
keys = rMap.keys;
tarIdx = find(temp == tarTemp);
for key = keys
    r = rMap(cell2mat(key));
    nowTemp = r(1, 4);
    nowIdx = find(temp == nowTemp);
    p = r(1, 2);
    f = zeros(2, size(r, 2));
    for i = 1: rNum
        for j = 1: pNum
            figure;
            colum = (i - 1) * pNum + j;
            %当前温度值的数据
            y0 = tdMatrix(:, nowIdx, colum);
            [fitresult, ~] = cruvFit(x, ...
                medfilt1(y0(index), filtParam(i, j)), ...
                'smoothingspline', fitParam(i, j));
            plot(x, fitresult(x), LineWidth=0.5); hold on;
            t0 = fitresult(p);
            %目标温度值的数据
            y1 = tdMatrix(:, tarIdx, colum);
            [fitresult, gof] = cruvFit(x, ...
                medfilt1(y1(index), filtParam(i, j)), ...
                'smoothingspline', fitParam(i, j));
            plot(x, fitresult(x), LineWidth=0.5); hold on;
            t1 = fitresult(p);
            t2 = r(1, colum + base - 1);
            %y0 - y2是温度相同下的补偿, 只包含暗电流的偏置, 不包含温漂
            f(1, colum + base - 1) = t0 - t2;
            %y1 - y2是直接补偿到目标温度值, 包含了温漂
            f(2, colum + base - 1) = t1 - t2;
        end
    end
    dMap(cell2mat(key)) = f;
end

save compensate.mat dMap;