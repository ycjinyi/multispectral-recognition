function [normalized_data] = normalize(data, lowerBound, upperBound)
% 此函数将数据归一化到需要的区间内, data只有1列
      
    % 找到原始数据的最大值和最小值  
    min_value = min(data);  
    max_value = max(data);     
    % 进行归一化  
    normalized_data = (data - min_value) / (max_value - min_value);  
    %缩放到需要的区间
    normalized_data = normalized_data * (upperBound - lowerBound) + lowerBound;
end