clc;
close all;
clear;

load dinoThickCompensate.mat

%读取补偿数据
comp = readmatrix("补偿.xlsx");
f = [
2024011703;
2024011901;
2024012001;
2024011903;
2024011705;
2024011905;
2024011707;
2024011709;
2024011907;
2024011711;
2024011909;
2024011911;
2024011713;
2024011715;
2024011717;
2024011719];

dMap = containers.Map("KeyType", "double", "ValueType", "any");
empty = zeros(1, 4);
for i = 1: size(comp, 1)
    dMap(f(i, 1)) = [empty, comp(i, :)];
end

%波段数目
pNum = 4;
%接收管数目
rNum = 3;

%读取目标文件夹下的所有数据
path = "冰水混合数据\加水数据\";
files = dir(fullfile(path,"*.xlsx"));
fileNames = {files.name};

%保存数据
data = [];
for i = 1: size(fileNames, 2)
    name = cell2mat(fileNames(1, i));
    file = fullfile(path, name);
    d = readmatrix(file);
    d = d + dMap(str2double(name(1, 1: end - 7)));
    %仅保留水的厚度在1mm以上的情况
    idx = find(d(:, 3) >= 1.0, 1);
    d = d(idx: end, :);
    %水厚度在7mm以上的情况也需要排除
    idx = find(d(:, 3) > 7.0, 1);
    if ~isempty(idx)
        d = d(1: idx - 1, :);
    end
    %对水的厚度进行补偿
    d(:, 3) = d(:, 3) + fitresult(d(:, 3));
    % d(:, 3) = d(:, 3) + 0.2;
    data = [data; d];
end

%将每一列的最大值统一化
tar = 20;
for i = 5: 8
    maxd = max(data(:, i));
    diff = tar - maxd;
    data(:, i) = data(:, i) + ones(size(data, 1), 1) * diff;
end


%作图展示, 三维坐标
for i = 1: rNum
    figure(i);
    for j = 1: pNum
        colum = 5 + (i - 1) * pNum + (j - 1);
        x = data(:, 2);
        y = data(:, 3);
        z = data(:, colum);
        scatter3(data(:, 2), data(:, 3), data(:, colum), 5, 'filled'); hold on;
    end
    legend("890", "1405", "1465", "1575");
    % legend("1405", "1465", "1575");
    ylabel("水厚");
    xlabel("冰厚");
    zlabel("响应");
    %ylim([0.01, 20]);
    %set(gca, "YScale", "log");
    grid on;
end

%根据数据进行拟合
ice = data(:, 2);
water = data(:, 3);
% z = data(:, 8);
v = data(:, 5: 8);

types = containers.Map("KeyType", 'double', "ValueType", 'char');
types(1) = "lowess";
types(2) = "lowess";
types(3) = "lowess";
types(4) = "lowess";
spans = [0.5, 0.3, 0.3, 0.3];
fitMap = containers.Map("KeyType", 'double', "ValueType", 'any');
for i = 1: size(v, 2)
    [fitresult, ~] = surfaceFit(ice, water, v(:, i), types(i), spans(1, i));
    fitMap(i) = fitresult;
end 

%目标的厚度区间
% 冰厚度不变
% wt = 2: 0.1: 4;
% it = ones(1, size(wt, 2)) * 3;


% 水厚度不变
% it = 2: 0.1: 4;
% wt = ones(1, size(it, 2)) * 2;

% 厚度都变
it = 1: 0.1: 3;
wt = 1: 0.1: 3;

% 总厚度不变
% it = 1.1: 0.05: 2.9;
% wt = 2.9: -0.05: 1.1;


% wt = 1.3 * it;
% wt = flip(wt);


%冰水起始的厚度和最终的厚度
begin = 2;
final = 6;
itBegin = begin / 2;
wtBegin = begin - itBegin;
dx = 10;
dt = 0.5;
incre = (final - begin);
points = 0: 0.1: incre;
lambdaStr = cell(1, size(points, 2));
resMap = containers.Map("KeyType", 'double', "ValueType", 'any');
cons = 100000;
keys = zeros(1, size(points, 2));
for i = 1: size(points, 2)
    p = points(1, i);
    iStep = p / dx;
    wStep = (incre - p) / dx;
    it = itBegin: iStep: itBegin + p;
    if iStep == 0
        it = ones(1, (incre - p) / wStep + 1) * itBegin;
    end
    wt = wtBegin: wStep: wtBegin + incre -p;
    if wStep == 0
        wt = ones(1, p / iStep + 1) * wtBegin;
    end
    res = zeros(4, size(it, 2));
    for j = 1: size(it, 2)
        for k = 1: 4
            fitResult = fitMap(k);
            res(k, j) = fitResult(it(1, j), wt(1, j));
        end
    end
    %将1465视为不变量
    tar = 10;
    coff = ones(1, size(res, 2)) * tar ./ res(3, :);
    for k = 1: size(res, 1)
        res(k, :) = res(k, :) .* coff;
    end
    %装入数据
    ratio = (itBegin + p) / (wtBegin + incre - p);
    lambdaStr(1, i) = {mat2str(floor(ratio * 100) / 100)};
    ratio = floor(ratio * cons);
    resMap(ratio) = res;
    keys(1, i) = ratio;
end

CG = ColorGenerator();
[colorTable, ~] = CG.generate(points);

%结果展示
figure;
for i = 1: size(keys, 2)
    r = resMap(keys(1, i));
    plot(r(1, :), 'Color', ...
      [colorTable(i, :), 0.6], LineWidth=0.7); hold on;
end
legend(lambdaStr);
xlabel("厚度点");
ylabel("响应");
grid on;

% %结果展示
% figure;
% for i = 2: size(res, 1)
%     plot(x, res(i, :)); hold on;
% end
% 
% 
% x = wt;
% str = "单层厚度";
% 
% figure;
% for i = 2: size(res, 1)
%     plot(x, res(i, :)); hold on;
% end
% % legend("890", "1405", "1465", "1575");
% legend("1405", "1465", "1575");
% xlabel(str);
% ylabel("响应");
% grid on;
% 
% 
% A = res(4, :) - res(3, :);
% B = res(2, :) - res(3, :);
% C = res(4, :) - res(2, :);
% figure;
% plot(x, A); hold on;
% plot(x, B ./ A);
% plot(x, C); hold on;
% legend("1575 - 1465", "(1405 - 1465) / (1575 - 1465)", "1575 - 1405");
% xlabel(str);
% ylabel("响应");
% grid on;


% %计算特征
% n890 = res(1, :);
% n1405 = res(2, :);
% n1465 = res(3, :);
% n1575 = res(4, :);
% 
% f = [n1405 ./ n890; n1465 ./ n890; n1575 ./ n890; 
%     n1465 ./ n1405; n1575 ./ n1405; n1575 ./ n1465];
% 
% %展示特征
% figure;
% for i = 1: size(f, 1)
%     plot(x, f(i, :)); hold on;
% end
% legend("1405 / 890", "1465 / 890", "1575 / 890", "1465 / 1405", "1575 / 1405", "1575 / 1465");
% % legend("1405", "1465", "1575");
% xlabel(str);
% ylabel("响应");
% grid on;