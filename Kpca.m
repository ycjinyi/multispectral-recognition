 function [kpcadata] = Kpca(data,threshold,rbf_var)
%kpca降维
% 
% if nargin <4
% rbf_var=10000;
% end
% if nargin <3
% threshold = 90;
% end

% %KPCA参数
% rbf_var=mean(pdist(data))^2;%各对行向量之间的平均距离
% threshold=90;

% 数据处理
patterns=data; 
sample_size=size(patterns,1); %sample_size是样本的个数

% 计算核矩阵pdata
K=zeros(sample_size,sample_size);
for i=1:sample_size
    for j=i:sample_size
        K(i,j)=exp((-(norm(patterns(i,:)-patterns(j,:)))^2)/rbf_var); %向量模的平方 核函数 rbf_var 
%         K(i,j)=(patterns(i,:)*patterns(j,:)'+c)^d;
        K(j,i)=K(i,j);
    end
end

n=sample_size;
% 求中心化矩阵
E=((1/n)*eye(n)-(1/n^2)*ones(n,n))*K;

% 特征值分解
[U,lambda]=eig(E);%求中心化K矩阵的特征值和特征向量
[lambda,I]=sort(diag(lambda),'descend');
U=U(:,I);

% 提取主成分  主成分所占的百分比>threshold
percentage=100*cumsum(lambda)./sum(lambda);%求得特征值累计所占百分比
index=find(percentage>threshold);%找到大于阈值的索引号

% 计算Up
p=index(1);
Up=zeros(n,p);
for i=1:p
    temp=U(:,i);
    Up(:,i)=temp/sqrt(temp'*K*temp);
end

%降维
kpcadata=(K-(1/n)*ones(n,n)*K)*Up;

end

