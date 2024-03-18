clc;
clear;
close all;

%此脚本主要用于手动划分训练集和测试集合, 并对数据进行训练测试, 最后展示结果

%-------->1 为数据分配标签
sets = {"结冰", 1; "积水", 2; "冰水混合", 3; "干雪", 4; "湿雪", 5; "空载", 6;
        "机油", 7; "防冻液", 8; "沙土", 9};
DM = DataManagement(sets);
%载入数据
DM.readFile(pwd + "\实验数据");

%-------->2 划分数据集合
%首先获取所有数据编号信息
snum = size(sets, 1);
dataSet = cell(snum, 2);
for i = 1: snum
    numbers = DM.getNumberBYLabel(i);
    dataSet(i, :) = {sets{i, 1}, numbers};
end
%训练集合包含的数据编号索引, 其余数据将作为测试集数据
trainSet = {
    "结冰",       {3, 2, 1}; 
    "积水",       {3, 2, 1}; 
    "冰水混合",   {3, 2, 1}; 
    "干雪",       {3, 2, 1}; 
    "湿雪",       {3, 2, 1}; 
    "空载",       {3, 2, 1};
    "机油",       {3, 2, 1};
    "防冻液",     {3, 2, 1};
    "沙土",       {3, 2, 1};};
%根据上述选择方式重新调整trainSet, 从索引转换为编号
for i = 1: snum
    idxs = cell2mat(trainSet{i, 2});
    numbers = dataSet{i, 2};
    number = numbers(idxs, 1);
    trainSet{i, 2} = number;
end
%获得划分后的训练集和测试集数据
[trainData, trainLabel, testData, testLabel] = DM.generateData(trainSet);

%保存每一种类别的数据在不同接收管下的均值和标准差
staData = zeros(snum, size(trainData, 2) * 2);
for i = 1: snum
    idx = find(trainLabel == i);
    data = trainData(idx, :) / 15;
    md = mean(data, 1);
    sd = std(data, [], 1);
    for j = 1: size(md, 2)
        staData(i, 2 * (j - 1) + 1) = md(1, j);
        staData(i, 2 * (j - 1) + 2) = sd(1, j);
    end
end
%将所有数据按照890nm为基准相比后的结果
uniData = zeros(snum, size(trainData, 2) * 2);
for i = 1: snum
    idx = find(trainLabel == i);
    data = trainData(idx, :) / 15;
    dataCopy = data;
    %将所有数据与890nm相比
    for j = 1: size(data, 2)
        idx = floor((j - 1) / 4);
        data(:, j) = data(:, j) ./ dataCopy(:, idx * 4 + 1);
    end
    md = mean(data, 1);
    sd = std(data, [], 1);
    for j = 1: size(md, 2)
        uniData(i, 2 * (j - 1) + 1) = md(1, j);
        uniData(i, 2 * (j - 1) + 2) = sd(1, j);
    end
end


%数据处理+特征选取
DP = DataProc();
[trainData, testData] = DP.dataProc(trainData, testData, 3);

CG = ColorGenerator();
[colorTable, lambdaStr] = CG.generate(zeros(1, 9));

%作图展示数据分布
figure(1);
for i = 1: snum
    idx = find(trainLabel == i);
    data = trainData(idx, :);
    plot3(data(:, 1), data(:, 2), data(:, 3), 'Color', colorTable(i, :), "Marker", "*", "LineStyle", "none"); hold on;
end
legend(sets{:, 1});
ylabel("第一主成分");
xlabel("第二主成分");
zlabel("第三主成分");
grid on;
