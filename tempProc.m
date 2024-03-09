clc;
clear;
close all;

%--------------------------------光电数据处理-------------------------------
%波段数目
pNum = 4;
%接收管数目
rNum = 3;
%读取目标xlsx文件
path = ".\";
fnum = 2024012503;
f = num2str(fnum);
file = strcat(path, f, "\pdata.xlsx");
d = readmatrix(file);
%精度调整
d(:, 3: end) = d(:, 3: end) / 15;
% %范围调整
% d = d(100: end, :);

% %对数据按照温度值进行降序排序
[~, index] = sort(d(:, 2));
decIndex = flipud(index);
d = d(decIndex, :);

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
%温度数据展示
figure;
plot(d(:, 2));
ylabel("温度");
xlabel("时间");
grid on;

%--------------------------------数据整合保存-------------------------------
%温漂时的厚度数据单位(mm)
%冰厚,水厚度
tf = num2str(fnum - 1);
thickFile = readmatrix(strcat(path, tf, "empty.xlsx"));
it = mean(thickFile(:, 2));
wt = 0;

% it = 0;
% wt = 8.940;

data = [d(:, 1), ones(size(d, 1), 1) * it, ones(size(d, 1), 1) * wt, d(:, 2: end)];

s = 5;
len = 9;
data(:, s) = medfilt1(data(:, s), len);
data(:, s + 1) = medfilt1(data(:, s + 1), len);
data(:, s + 2) = medfilt1(data(:, s + 2), len);
data(:, s + 3) = medfilt1(data(:, s + 3), len);

%对接收光纤2的890, 1405, 1465, 1575nm波段进行滤波
data(:, s + 4) = medfilt1(data(:, s + 4), len);
data(:, s + 5) = medfilt1(data(:, s + 5), len);
data(:, s + 6) = medfilt1(data(:, s + 6), len);
data(:, s + 7) = medfilt1(data(:, s + 7), len);

%对接收光纤3的890, 1405, 1465, 1575nm波段进行滤波
data(:, s + 8) = medfilt1(data(:, s + 8), 19);
data(:, s + 9) = medfilt1(data(:, s + 9), len);
data(:, s + 10) = medfilt1(data(:, s + 10), len);
data(:, s + 11) = medfilt1(data(:, s + 11), len);

newData = data;

%目标数据
tempUpperLimit = 12;
tempLowerLimit = -1;
%以0.05的温度点间隔重做数据
temp = tempLowerLimit: 0.05: tempUpperLimit;

finalData = zeros(size(temp, 2), size(data, 2));
finalData(:, 4) = temp;
finalData(:, 3) = wt * ones(size(finalData, 1), 1);
finalData(:, 2) = it * ones(size(finalData, 1), 1);

%通过曲线拟合的方式修正数据
for i = 5: size(data, 2)
    [fitresult, gof] = cruvFit(data(:, 4), data(:, i), 'poly3');
    newData(:, i) = fitresult(data(:, 4));
    finalData(:, i) = fitresult(temp');
end

%统计最小值
minDdata = min(data);

%--------------------------------温漂数据展示-------------------------------
%作图展示
for i = 1: rNum
    figure;
    for j = 1: pNum
        colum = 5 + (i - 1) * pNum + (j - 1);
        % plot(data(:, 3), data(:, colum) - minDdata(:, colum) + 0.5); hold on;
        % plot(newData(:, 3), newData(:, colum) - minDdata(:, colum) + 0.5); hold on;
        plot(data(:, 4), data(:, colum)); hold on;
        plot(newData(:, 4), newData(:, colum)); hold on;
    end
    %legend("890", "1405", "1465", "1575");
    legend("890", "890-1", "1405", "1405-1", "1465", "1465-1", "1575", "1575-1");
    ylabel("响应");
    xlabel("温度");
    set(gca, "YScale", "log");
    grid on;
end

%--------------------------------最终数据展示-------------------------------
%作图展示
% for i = 1: rNum
%     figure;
%     for j = 1: pNum
%         colum = 5 + (i - 1) * pNum + (j - 1);
%         plot(finalData(:, 4), finalData(:, colum)); hold on;
%     end
%     legend("890", "1405", "1465", "1575");
%     ylabel("响应");
%     xlabel("温度");
%     ylim([0.09, 20])
%     set(gca, "YScale", "log");
%     grid on;
% end

writematrix(finalData, strcat(path, f, "\", f,"empty.xlsx"));