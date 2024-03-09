function [fitresult, gof] = cruvFit(varargin)
%x, y, type, param
%x是横坐标,y是需要拟合的纵坐标
numParams = nargin; 
params = varargin;
x = params{1};
y = params{2};
type = params{3};
param = 0.85;
if numParams == 4
    param = params{4};
end

[xData, yData] = prepareCurveData(x, y);
% 设置 fittype 和选项 'smoothingspline'是平滑样条
ft = fittype(type);
if strcmpi(type, "smoothingspline")
    opts = fitoptions( 'Method', 'SmoothingSpline' );
    %0.942624028257546
    %0.9087976585258021
    %0.8580322662796418
    %0.7856736923421046
    %0.6897694971043692
    opts.SmoothingParam = param;
    [fitresult, gof] = fit(xData, yData, ft, opts);
else
    % 对数据进行模型拟合。
    [fitresult, gof] = fit(xData, yData, ft);
end



