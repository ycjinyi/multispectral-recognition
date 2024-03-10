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
%获得划分后的训练集和测试集数据
[trainData, trainLabel, testData, testLabel] = DM.generateData(trainSet);

%数据处理+特征选取

% %标准化处理
% amiddata=zscore([middata(1,:) middata(2,:) middata(3,:)]');%对每一列标准化 即对每个接收管的数据归一化
% 
% %归一化处理
% [amiddata] = mapminmax(amiddata');%对每一列归一化处理 即对每个接收管的数据归一化
% amiddata=[amiddata(1,1:peaknum*labelnum);amiddata(1,peaknum*labelnum+1:2*peaknum*labelnum);amiddata(1,peaknum*labelnum*2+1:3*peaknum*labelnum)];
% %重新组合为二维数组
% finaldata=zeros(labelnum,peaknum*recnum);%每一行为一个样本
%  for i=1:labelnum
%       for j=1:recnum
%          for k=1:peaknum
%             finaldata(i,(j-1)*peaknum+k)=amiddata(j,(i-1)*peaknum+k);
%          end
%      end
%  end
% 
% [COEFF,amiddata]=pca(finaldata);%PCA

%------->3 模型训练和预测结果展示



