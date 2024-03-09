function [fitresult, gof] = surfaceFit(x, y, z, type, span)
%x是冰厚,y是水厚度,z是响应
%type是拟合类型, lowess 是线性拟合, loess 是二次拟合
%span是跨度

[xData, yData, zData] = prepareSurfaceData( x, y, z );
% 设置 fittype
ft = fittype(type);
opts = fitoptions('Method', 'LowessFit' );
opts.Normalize = 'on';
opts.Span = span;

% 对数据进行模型拟合
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );


