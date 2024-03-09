clc
clear all

length1=4;
length2=10;
angel=[0:0.5:360];
len=size(angel,2);
theta=angel*2*pi/360;
x1=length1*cos(theta);
y1=length1*sin(theta);
x2=length2*cos(theta);
y2=length2*sin(theta);

for i=1:len 
    x1(1,i)=x1(1,i)+randn(1);
    y1(1,i)=y1(1,i)+randn(1);
    x2(1,i)=x2(1,i)+randn(1);
    y2(1,i)=y2(1,i)+randn(1);
end

data=[x1',y1';x2',y2'];

figure;
plot(data(1:len,1),data(1:len,2),'r--o');hold on
plot(data(len+1:end,1),data(len+1:end,2),'b*');
title('原始数据')

[COEFF,pdata]=pca(data);%PCA
figure;

plot(pdata(1:len,1),pdata(1:len,2),'r--o');hold on
plot(pdata(len+1:end,1),pdata(len+1:end,2),'b*');
title('PCA')

%KPCA参数
rbf_var=1000;
threshold = 90;

% 数据处理
patterns=data; 
num=size(patterns,1); %num是样本的个数
cov_size = num; %cov_size是样本的个数

% 计算核矩阵
K=zeros(cov_size,cov_size);
for i=1:cov_size
    for j=i:cov_size
        K(i,j)=exp(-norm(patterns(i,:)-patterns(j,:))^2/rbf_var); %向量模的平方 核函数 rbf_var 
        K(j,i)=K(i,j);
    end
end

c=1/cov_size;%常数系数

% 求中心化矩阵
K_n=c*(eye(cov_size)-c*c*ones(cov_size,cov_size))*K;

% 特征值分解
[evectors_1,evalues_1]=eig(K_n);%求中心化K矩阵的特征值和特征向量
[x,index_1]=sort(real(diag(evalues_1)));%sort每行按从小到大排序，x为排序后结果，index为索引 diag是取对角线上的元素 real是取实部 对特征值进行排序
evalues=flipud(x) ;%flipud函数实现矩阵的上下翻转 翻转特征值，使其从大到小排序
index_1=flipud(index_1);%同样翻转索引

% 将特征向量按特征值的大小顺序排序
evectors=evectors_1(:,index_1);%每列为一个特征向量

% 计算归一化系数
coefficient=ones(cov_size,1)./sqrt(real(diag(evectors'*K*evectors)));

% 计算Up矩阵
Up=real(coefficient'.*evectors);

% 提取主成分  主成分所占的百分比>threshold
percentage=100*cumsum(evalues)./sum(evalues);%求得特征值累计所占百分比
index=find(percentage>threshold);%找到大于阈值的索引号
% kpcadata=zeros(cov_size,index(1)); %train_num是训练样本的个数 index(1)代表第一个方差贡献率达到threshold的特征值索引

% 将训练数据进行映射，达到降维的目的！
kpcadata=(K-c*ones(cov_size,cov_size)*K)*Up(:,1:index(1));


figure;
plot(kpcadata(1:len,1),kpcadata(1:len,2),'r--o');hold on
plot(kpcadata(len+1:end,1),kpcadata(len+1:end,2),'b*');
title('KPCA')

figure;
plot(kpcadata(1:len,1),'r--o');hold on
plot(kpcadata(len+1:end,1),'b*');
title('KPCA')