function [trainedClassifier, validationAccuracy] = trainClassifier(trainingData, responseData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData,
% responseData)
% 返回经过训练的分类器及其 准确度。以下代码重新创建在分类学习器中训练的分类模型。您可以使用
% 该生成的代码基于新数据自动训练同一模型，或通过它了解如何以程序化方式训练模型。
%
%  输入:
%      trainingData: 一个与导入 App 中的矩阵具有相同列数和数据类型的矩阵。
%
%      responseData: 一个与导入 App 中的向量具有相同数据类型的向量。responseData 的
%       长度和 trainingData 的行数必须相等。
%
%
%  输出:
%      trainedClassifier: 一个包含训练的分类器的结构体。该结构体中具有各种关于所训练分
%       类器的信息的字段。
%
%      trainedClassifier.predictFcn: 一个对新数据进行预测的函数。
%
%      validationAccuracy: 以百分比形式表示验证准确度的双精度值。在 App 中，"模型"
%       窗格显示每个模型的验证准确度。
%
% 使用该代码基于新数据来训练模型。要重新训练分类器，请使用原始数据或新数据作为输入参数
% trainingData 和 responseData 从命令行调用该函数。
%
% 例如，要重新训练基于原始数据集 T 和响应 Y 训练的分类器，请输入:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T, Y)
%
% 要使用返回的 "trainedClassifier" 对新数据 T2 进行预测，请使用
%   [yfit,scores] = trainedClassifier.predictFcn(T2)
%
% T2 必须是仅包含用于训练的预测变量列的矩阵。有关详细信息，请输入:
%   trainedClassifier.HowToPredict

% 由 MATLAB 于 2024-03-17 09:40:38 自动生成


% 提取预测变量和响应
% 以下代码将数据处理为合适的形状以训练模型。
%
% 将输入转换为表
inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7'});

predictorNames = {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7'};
predictors = inputTable(:, predictorNames);
response = responseData;
isCategoricalPredictor = [false, false, false, false, false, false, false];
classNames = [1; 2; 3; 4; 5; 6; 7; 8; 9];

% 训练分类器
% 以下代码指定所有分类器选项并训练分类器。
template = templateLinear(...
    'Learner', 'SVM', ...
    'Lambda', 'auto', ...
    'BetaTolerance', 0.0001);
classificationLinear = fitcecoc(...
    predictors, ...
    response, ...
    'Learners', template, ...
    'Coding', 'onevsone', ...
    'ClassNames', classNames);

% 使用 predict 函数创建结果结构体
predictorExtractionFcn = @(x) array2table(x, 'VariableNames', predictorNames);
classificationLinearPredictFcn = @(x) predict(classificationLinear, x);
trainedClassifier.predictFcn = @(x) classificationLinearPredictFcn(predictorExtractionFcn(x));

% 向结果结构体中添加字段
trainedClassifier.ClassificationLinear = classificationLinear;
trainedClassifier.About = '此结构体是从分类学习器 R2023b 导出的训练模型。';
trainedClassifier.HowToPredict = sprintf('要对新预测变量列矩阵 X 进行预测，请使用: \n [yfit,scores] = c.predictFcn(X) \n将 ''c'' 替换为作为此结构体的变量的名称，例如 ''trainedModel''。\n \nX 必须包含正好 7 个列，因为此模型是使用 7 个预测变量进行训练的。\nX 必须仅包含与训练数据具有完全相同的顺序和格式的\n预测变量列。不要包含响应列或未导入 App 的任何列。\n \n有关详细信息，请参阅 <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>。');

% 提取预测变量和响应
% 以下代码将数据处理为合适的形状以训练模型。
%
% 将输入转换为表
inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7'});

predictorNames = {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7'};
predictors = inputTable(:, predictorNames);
response = responseData;
isCategoricalPredictor = [false, false, false, false, false, false, false];
classNames = [1; 2; 3; 4; 5; 6; 7; 8; 9];

% 执行交叉验证
KFolds = 5;
cvp = cvpartition(response, 'KFold', KFolds);
% 将预测初始化为适当的大小
validationPredictions = response;
numObservations = size(predictors, 1);
numClasses = 9;
validationScores = NaN(numObservations, numClasses);
for fold = 1:KFolds
    trainingPredictors = predictors(cvp.training(fold), :);
    trainingResponse = response(cvp.training(fold), :);
    foldIsCategoricalPredictor = isCategoricalPredictor;

    % 训练分类器
    % 以下代码指定所有分类器选项并训练分类器。
    template = templateLinear(...
        'Learner', 'SVM', ...
        'Lambda', 'auto', ...
        'BetaTolerance', 0.0001);
    classificationLinear = fitcecoc(...
        trainingPredictors, ...
        trainingResponse, ...
        'Learners', template, ...
        'Coding', 'onevsone', ...
        'ClassNames', classNames);

    % 使用 predict 函数创建结果结构体
    classificationLinearPredictFcn = @(x) predict(classificationLinear, x);
    validationPredictFcn = @(x) classificationLinearPredictFcn(x);

    % 向结果结构体中添加字段

    % 计算验证预测
    validationPredictors = predictors(cvp.test(fold), :);
    [foldPredictions, foldScores] = validationPredictFcn(validationPredictors);

    % 按原始顺序存储预测
    validationPredictions(cvp.test(fold), :) = foldPredictions;
    validationScores(cvp.test(fold), :) = foldScores;
end

% 计算验证准确度
correctPredictions = (validationPredictions == response);
isMissing = isnan(response);
correctPredictions = correctPredictions(~isMissing);
validationAccuracy = sum(correctPredictions)/length(correctPredictions);
