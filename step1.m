clc;
clear;
close all;

%保存数据的列
dataCol = 4;
%温度所在的行
tempRow = 1;
%890nm波段第一路接收的起始行
p890 = 4;
%波段数目
pNum = 4;
%接收管数目
rNum = 3;
%时间数据的列
timeCol = 5;
%每帧数据的行数
dataFrame = 30;

%读取目标xlsx文件
path = "2024012803";
file = strcat(path, "\data.xlsx");

%存储数据
d = readmatrix(file);
[r, c] = size(d);
if mod(r, dataFrame) ~= 0
    sprintf("数据帧不完整, 请检查后再处理!")
    return;
end
%计算新的行数和列数
row = floor(r / dataFrame);
%时间 + 温度 + 接收管数目 * 波段数目
col = 1 + 1 + pNum * rNum;
data = zeros(row, col);

T = Time();

%保存数据
for i = 1: row
    begin = (i - 1) * dataFrame;
    %保存时间和温度
    data(i, 1) =T.time2Int(T.convertDate(d(begin + tempRow, timeCol)));
    data(i, 2) = d(begin + tempRow, dataCol);
    %保存电压数据
    for j = 1: rNum
        for k = 1: pNum
           %原位置
           dp = p890 + (k - 1) * rNum + (j - 1);
           %新位置
           np = 3 + (j - 1) * pNum + (k - 1);
           data(i, np) = d(begin + dp, dataCol);
        end
    end   
end
writematrix(data, strcat(path, "\pdata.xlsx"));
