clc;
clear;
close all;

%此脚本主要用于手动划分训练集和测试集合, 并对数据进行训练测试, 最后展示结果

%-------->1 为数据分配标签
sets = {"凇冰", 1; "干雪", 2; "明冰", 3; "湿雪", 4; "防冻液", 5; "霜", 6};
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
    "凇冰",   {1}; 
    "干雪",   {1, 3}; 
    "明冰",   {1, 3, 5, 7, 9}; 
    "湿雪",   {1, 3}; 
    "防冻液", {1}; 
    "霜",     {1}};
%根据上述选择方式重新调整trainSet, 从索引转换为编号
for i = 1: snum
    idxs = cell2mat(trainSet{i, 2});
    numbers = dataSet{i, 2};
    number = numbers(idxs, 1);
    trainSet{i, 2} = number;
end
% %获得划分后的训练集和测试集数据
% [trainData, trainLabel, testData, testLabel] = DM.generateData(trainSet);
% 
% %数据处理+特征选取
% DP = DataProc();
% [trainData, testData] = DP.dataProc(trainData, testData, 0.90);
% 
% %------->3 模型训练和预测交由matlab工具箱
% save 2024031001.mat trainedModel trainData testData trainLabel testLabel DM DP;

load 2024031001.mat;
%进行数据预测和分析
[testPredict, ~] = trainedModel.predictFcn(testData);
%计算识别准确率和混淆矩阵
confusionMatrix = zeros(snum, snum);
for i = 1: snum
    nowLabel = i;
    %GT
    idxs = find(testLabel == nowLabel);
    %predict
    res = testPredict(idxs, 1);
    %装入混淆矩阵
    for j = 1: size(res, 1)
        confusionMatrix(i, res(j, 1)) = 1 + confusionMatrix(i, res(j, 1));
    end
end
%计算准确率
acc = zeros(1, snum);
for i = 1: size(acc, 2)
    if sum(confusionMatrix(:, i)) == 0
        continue;
    end
    acc(1, i) = confusionMatrix(i, i) / sum(confusionMatrix(:, i));
end
%计算召回率
recall = zeros(1, snum);
for i = 1: size(recall, 2)
    if sum(confusionMatrix(i, :)) == 0
        continue;
    end
    recall(1, i) = confusionMatrix(i, i) / sum(confusionMatrix(i, :));
end
%计算F1分数
F1Score = zeros(1, snum);
for i = 1: size(F1Score, 2)
    if acc(1, i) + recall(1, i) == 0
        continue;
    end
    F1Score(1, i) = 2 * acc(1, i) * recall(1, i) / (acc(1, i) + recall(1, i));
end




