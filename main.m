clc
clear all
close all

nowpath = 'C:\study\多光谱传感器\实验数据\光纤探头\'; %当前文件路径  

%该程序有一个问题，就是只能处理每种条件下的一组数据
%读取当前文件夹下所有csv文件
targetFile=dir(fullfile(nowpath,'*.csv'));
targetFilenames={targetFile.name};
[~,len]=size(targetFilenames);
labelnum=12;%12种标签
peaknum=4;%4个波段
recnum=3;%3个接收管
alldata=zeros(peaknum,2*recnum,labelnum);
for j=1:len
      nowfilename=cell2mat(targetFilenames(1,j));
      
      [data,label] = data_process(peaknum,nowpath,nowfilename);
      %按照值的状态和标签装数据
      if contains(nowfilename,'初始')
        alldata(:,1:recnum,label)=data;%初始值放在左边
      else
        alldata(:,recnum+1:2*recnum,label)=data;%稳态值放在右边   
      end                
end 
alldata(:,recnum+1,8)=[0.17;0.14;0.04;0.01];
diffdata=alldata(:,recnum+1:2*recnum,:)-alldata(:,1:recnum,:);%求差结果

diffdata(:,1,:)=diffdata(:,1,:)*1.5;
diffdata(:,3,:)=diffdata(:,3,:)*2.5;
%difratdata=diffdata./alldata(:,1:recnum,:);%求差结果比上初始值
difratdata=diffdata;%求差结果
%将三维数组放到二维数组中
pdata=zeros(labelnum,recnum*peaknum);

for j=1:recnum
    for i=1:peaknum
        for k=1:labelnum
            pdata(k,(j-1)*peaknum+i)=difratdata(i,j,k); 
        end
    
    end
end

middata=zeros(recnum,labelnum*peaknum);
for i=1:recnum
    for j=1:labelnum
        for k=1:peaknum
            middata(i,(j-1)*peaknum+k)=pdata(j,(i-1)*peaknum+k);
        end  
    end
end
    

%标准化处理
amiddata=zscore([middata(1,:) middata(2,:) middata(3,:)]');%对每一列标准化 即对每个接收管的数据归一化

%归一化处理
[amiddata] = mapminmax(amiddata');%对每一列归一化处理 即对每个接收管的数据归一化
amiddata=[amiddata(1,1:peaknum*labelnum);amiddata(1,peaknum*labelnum+1:2*peaknum*labelnum);amiddata(1,peaknum*labelnum*2+1:3*peaknum*labelnum)];
%重新组合为二维数组
finaldata=zeros(labelnum,peaknum*recnum);%每一行为一个样本
 for i=1:labelnum
      for j=1:recnum
         for k=1:peaknum
            finaldata(i,(j-1)*peaknum+k)=amiddata(j,(i-1)*peaknum+k);
         end
     end
 end
 
[COEFF,amiddata]=pca(finaldata);%PCA
%归一化处理
% [amiddata] = mapminmax(amiddata');
% amiddata=amiddata';

figure;
imagesc(amiddata(:,:));
colorbar;

%KPCA 
% rbf_var=mean(pdist(finaldata))^2;%各对行向量之间的平均距离
rbf_var=3;
threshold=90;
kpcadata=Kpca(finaldata,threshold,rbf_var);

% 归一化处理
% [kpcadata] = mapminmax(kpcadata');
% kpcadata=kpcadata';

figure;
imagesc(kpcadata(:,:));
colorbar;



figure;
imagesc(finaldata(:,:));
colorbar;

% figure;
% imagesc(finaldata(:,5:8));
% colorbar;
% 
% figure;
% imagesc(finaldata(:,9:12));
% colorbar;



%找不同接收管的最大最小值
% maxnum=zeros(labelnum,2*recnum);
% minnum=zeros(labelnum,2*recnum);
% A=max(alldata);
% B=min(alldata);
% for i=1:labelnum
%     maxnum(i,:)=A(:,:,i);
%     minnum(i,:)=B(:,:,i);
% end
% C=max(maxnum);
% D=min(minnum);