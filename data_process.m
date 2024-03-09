function [findata,label] = data_process(peaknum,nowpath,nowfilename)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
    nowfile=fullfile(nowpath,nowfilename);%当前被选中文件路径
    data=csvread(nowfile,0,0);
    [row,column]=size(data);
    aftdata=zeros(row,column);
    nowstate=0;
    if contains(nowfilename,'初始')
        start=2;
    else
        start=1;
    end       
  %通过状态机得出每个峰值和低谷的值
    for j=start:column
        max=data(1,j);%初始化当前列的最大值
        min=data(1,j);%初始化当前列的最小值
        count=1;
       
        for i=1:row-1
            
            if nowstate==0 %下降状态
                if data(i+1,j)-data(i,j)>0.003%如果出现电压值变大的情况则进入上升状态
                    nowstate=1;
                    max=data(i+1,j);
                    aftdata(count,j)=min;%此时保存之前得到的最小值
                    count=count+1;
                elseif data(i+1,j)<min%若在下降状态则找出最小值
                    min=data(i+1,j);
                end
                
            elseif nowstate==1%上升阶段
                 if data(i,j)-data(i+1,j)>0.003%如果出现电压值变小的情况，则进入下降状态
                    nowstate=0;
                    min=data(i+1,j);
                    aftdata(count,j)=max;%此时保存之前得到的最大值
                    count=count+1;
                elseif data(i+1,j)>max%若在上升状态则找出最大值
                    max=data(i+1,j);
                 end
                
            end
            
        end
    end
    
  
    %去掉第一个没有经过比较的初值以及后面没有数据的零值
    aftdata=aftdata(2:count-1,1:column);
    
    sum=zeros(peaknum+1,column+1);%需要多一个保存的数，用于保存波谷值
    %求平均响应值
    len=size(aftdata,1);
    for i=1:len
        switch mod(i,2*peaknum)%波峰的序号
            case 1
                sum(1,1:column)=sum(1,1:column)+aftdata(i,1:column);
                sum(1,1+column)=sum(1,1+column)+1;%计数
            case 3
                sum(2,1:column)=sum(2,1:column)+aftdata(i,1:column);
                sum(2,1+column)=sum(2,1+column)+1;
            case 5
                sum(3,1:column)=sum(3,1:column)+aftdata(i,1:column);
                sum(3,1+column)=sum(3,1+column)+1;
            case 7
                sum(4,1:column)=sum(4,1:column)+aftdata(i,1:column);
                sum(4,1+column)=sum(4,1+column)+1;
            otherwise
                sum(5,1:column)=sum(5,1:column)+aftdata(i,1:column);
                sum(5,1+column)=sum(5,1+column)+1;
        end 
    end
    
    sum(:,1:column)=sum(:,1:column)./sum(:,1+column);%求平均值  
    
    findata=zeros(peaknum,column);
    for i=1:peaknum%所有接收管的波峰值减去对应的波谷值
        findata(i,:)=sum(i,1:column)-sum(end,1:column);  
    end
    
    %补上不好检测的第一列，用均值代替
    if start~=1
         findata(:,1)=ones(peaknum,1)*mean(data(:,1));
    end
  
%   作图显示波形
%     figure;
%     for i=1:column
%         plot(findata(:,i));
%         hold on;
%     end
%     title(nowfilename);
    
    %贴标签
    if contains(nowfilename,'积水')
        label=1;
            
    elseif contains(nowfilename,'积雪')
        label=2;
 
    elseif contains(nowfilename,'霜')
        label=3;
    
    elseif contains(nowfilename,'凇冰')
        label=4;
    
    elseif contains(nowfilename,'混合冰片1mm')
        label=5;
    
    elseif contains(nowfilename,'混合冰片2mm')
        label=6;
    
    elseif contains(nowfilename,'混合冰片3mm')
        label=7;
      
    elseif contains(nowfilename,'混合冰偏明')
        label=8;
       
    elseif contains(nowfilename,'明冰')
        label=9;
        
    elseif contains(nowfilename,'毛巾')
        label=10;
        
    elseif contains(nowfilename,'纸')
        label=11;
        
    elseif contains(nowfilename,'人')
        label=12;
   
    end
    
   
end

