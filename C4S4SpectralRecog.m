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

%-------->2 进行循环验证
% [testLabel, testPredict] = crossValidation(DM, 3);

% save 2024031801.mat testLabel testPredict;

load 2024031801.mat;

snum = size(sets, 1);
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

%计算总体的准确率
all = size(testLabel, 1);
right = 0;
for i = 1: size(testLabel, 1)
    if testLabel(i, 1) == testPredict(i, 1)
        right = right + 1;
    end
end
total = right / all;