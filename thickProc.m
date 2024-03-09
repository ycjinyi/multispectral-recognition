clc;
clear;
close all;

%--------------------------------光电数据处理-------------------------------
%波段数目
pNum = 4;
%接收管数目
rNum = 3;
%读取目标xlsx文件
path = "2024011719";
file = strcat(path, "\pdata.xlsx");
d = readmatrix(file);
%精度调整
d(:, 3: end) = d(:, 3: end) / 15;

%对接收光纤1的890, 1405, 1465, 1575nm波段进行滤波
s = 3;
d(:, s) = medfilt1(d(:, s), 5);
d(:, s + 1) = medfilt1(d(:, s + 1), 7);
d(:, s + 2) = medfilt1(d(:, s + 2), 7);
d(:, s + 3) = medfilt1(d(:, s + 3), 7);
% 
% %对接收光纤2的890, 1405, 1465, 1575nm波段进行滤波
d(:, s + 4) = medfilt1(d(:, s + 4), 5);
d(:, s + 5) = medfilt1(d(:, s + 5), 5);
d(:, s + 6) = medfilt1(d(:, s + 6), 5);
d(:, s + 7) = medfilt1(d(:, s + 7), 5);
% 
% %对接收光纤3的890, 1405, 1465, 1575nm波段进行滤波
d(:, s + 8) = medfilt1(d(:, s + 8), 27);
d(:, s + 9) = medfilt1(d(:, s + 9), 5);
d(:, s + 10) = medfilt1(d(:, s + 10), 5);
d(:, s + 11) = medfilt1(d(:, s + 11), 5);

% d = d(266: end, :);

%作图展示
for i = 1: rNum
    figure;
    for j = 1: pNum
        colum = 3 + (i - 1) * pNum + (j - 1);
        %plot(1:1:size(d, 1), d(:, colum) - minDdata(:, colum) + 0.1); hold on;
        plot(1:1:size(d, 1), d(:, colum)); hold on;
    end
    legend("890", "1405", "1465", "1575");
    ylabel("响应");
    xlabel("时间");
    set(gca, "YScale", "log");
    grid on;
end


%--------------------------------厚度数据处理-------------------------------
%读取对应的.txt文件, 用于厚度匹配
time2IceThick = containers.Map("KeyType", 'double', "ValueType", 'double');
time2WaterThick = containers.Map("KeyType", 'double', "ValueType", 'double');
thickFile = strcat(path, "\", path, ".txt");
thickData = importdata(thickFile);

thickData(:, 2) = medfilt1(thickData(:, 2), 5);
thickData(:, 3) = medfilt1(thickData(:, 3), 7);

thickData = thickData(120: end, :);

figure;
plot(thickData(:, 2)); hold on;
plot(thickData(:, 3) - thickData(:, 2));
grid on;
ylabel("厚度");
xlabel("时间");
legend("冰厚度", "水厚度")
%转换为map
for i = 1: size(thickData, 1)
    time = thickData(i, 1);
    iceThick = thickData(i, 2);
    waterThick = thickData(i, 3) - iceThick;
    time2IceThick(time) = iceThick;
    % waterThick = thickData(i, 2);
    time2WaterThick(time) = waterThick;
end

%--------------------------------数据整合-------------------------------
%data的第1列是时间, 第2列是第1层介质的厚度, 第3列是第2层介质的厚度
data = zeros(size(d, 1), size(d, 2) + 2);
row = 0;
for i = 1: size(d, 1)
    time = d(i, 1);
    if ~isKey(time2WaterThick, time)
        continue;
    end
    %需要将负数去掉
    iceThick = max(time2IceThick(time), 0);
    waterThick = max(time2WaterThick(time), 0);
    % iceThick = 0;
    row = row + 1;
    data(row, :) = [d(i, 1), iceThick, waterThick, d(i, 2: end)];
end
data = data(1: row, :);

%--------------------------------数据展示---------------------------------
%统计最小值
minDdata = min(data);

for i = 1: rNum
    figure;
    for j = 1: pNum
        colum = 5 + (i - 1) * pNum + (j - 1);
        % plot(data(:, 3), ...
        %     data(:, colum) - minDdata(:, colum)); hold on;
        plot(1: size(data, 1), ...
            data(:, colum)); hold on;
    end
    legend("890", "1405", "1465", "1575");
    ylabel("响应");
    %xlabel("水厚度");
    xlabel("数据点");
    ylim([0.09, 20]);
    set(gca, "YScale", "log");
    grid on;
end

figure;
plot(data(:, 2)); hold on;
plot(data(:, 3)); hold on;
plot(data(:, 4));
grid on;
xlabel("数据点");
legend("冰厚度", "水厚度", "温度");
ylim([-6, 12]);

% writematrix(data, strcat(path, "\", path, "down.xlsx"));
% writematrix(data, strcat(path, "\", path, "up.xlsx"));