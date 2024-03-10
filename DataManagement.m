classdef DataManagement < DataAttribute
%该类用于管理不同类别的实验数据, 并提供快速获取数据的接口

    properties

        %数据类别和标签对应的集合
        name2Label;
        label2Name;
        %标签和数据对应的集合
        label2Data;

        %保存数据的列
        dataCol = 4;
        %温度所在的行
        tempRow = 1;
        %890nm波段第一路接收的起始行
        p890 = 4;
        %时间数据的列
        timeCol = 5;
        %每帧数据的行数
        dataFrame = 30;
    end

    methods
        %根据sets中名称和标签的对应关系创建DataManagement
        %sets示例：{"明冰", 1; "凇冰", 2}
        function obj = DataManagement(sets)
            obj = obj@DataAttribute();
            obj.name2Label = containers.Map("KeyType", 'char', "ValueType", 'double');
            obj.label2Name = containers.Map("KeyType", "double", "ValueType", "char");
            obj.label2Data = containers.Map("KeyType", "double", "ValueType", "any");  
            %根据sets设置基本参数
            for i = 1: size(sets, 1)
                name = sets{i, 1};
                label = sets{i, 2};
                obj.name2Label(name) = label;
                obj.label2Name(label) = name;
            end
        end
        
        %此函数目标文件夹下读取数据并保存
        function readFile(obj, path)
            %获得目标路径下的所有文件夹名称
            names = dir(fullfile(path, '*'));
            for i = 1: length(names)
                name = names(i).name;
                if ~isKey(obj.name2Label, name)
                    continue;
                end
                %创建一个map保存当前类别的数据
                number2Data = containers.Map("KeyType", "double", "ValueType", "any");
                nowPath = path + "\" + name;
                %找到目标路径下的所有文件夹, 按照编号读取后保存
                tarNames = dir(fullfile(nowPath));
                for j = 1: length(tarNames)
                    tarName = tarNames(j).name;
                    if tarName == "." || tarName == ".."
                        continue;
                    end
                    nowFile = nowPath + "\" + tarName;
                    %如果存在pdata文件就不需要再次处理了，可以直接读取
                    if ~isfile(nowFile + "\pdata.xlsx")
                        data = readAndWrite(nowFile);
                    else 
                        data = readmatrix(nowFile + "\pdata.xlsx");
                    end
                    %获取编号
                    number = str2double(tarName);
                    %不需要最开始的时间戳信息和温度信息
                    number2Data(number) = data(:, 3: end);
                end
                %保存当前类别的所有数据
                obj.label2Data(obj.name2Label(name)) = number2Data;
            end
        end

        %名称转标签
        function label = fName2Label(obj, name)
            if ~isKey(obj.name2Label, name)
                return;
            end
            label = obj.name2Label(name);
        end

        %标签转名称
        function name = fLabel2Name(obj, label)
            if ~isKey(obj.label2Name, label)
                return;
            end
            name = obj.label2Name(label);
        end

        %获取数据的接口
        %name代表类别, numbers数组是需要获取的数据编号, 按行取
        function data = getDataBYName(obj, name, numbers)
            if ~isKey(obj.name2Label, name)
                return;
            end
            %获取对应类别的data
            number2Data = obj.label2Data(obj.name2Label(name));
            data = [];
            ridx = 1;
            for i = 1: size(numbers, 1)
                if ~isKey(number2Data, numbers(i, 1))
                    continue;
                end
                rowData = number2Data(numbers(i, 1));
                [r, c] = size(rowData);
                data(ridx: ridx + r - 1, 1: c) = rowData;
                ridx = ridx + r;
            end
        end   

        %获取数据的接口
        %label代表类别的标签, numbers数组是需要获取的数据编号, 按行取
        function data = getDataBYLabel(obj, label, numbers)
            if ~isKey(obj.label2Name, label)
                return;
            end
            data = obj.getDataBYName(obj.label2Name(label), numbers);
        end

        %通过类别名称获取对应的所有数据编号
        function numbers = getNumberBYName(obj, name)
            if ~isKey(obj.name2Label, name)
                return;
            end
            number2Data = obj.label2Data(obj.name2Label(name));
            keySets = keys(number2Data);
            keyNums = size(keySets, 2);
            numbers = zeros(keyNums, 1);
            for i = 1: keyNums
                numbers(i, 1) = keySets{1, i};
            end
        end

        %通过类别标签获取对应的所有数据编号
        function numbers = getNumberBYLabel(obj, label)
            if ~isKey(obj.label2Name, label)
                return;
            end
            numbers = obj.getNumberBYName(obj.label2Name(label));
        end

        %根据指定的划分方式, 将数据划分为训练集和测试集合数据并返回
        %注意数据都是按行存储
        %trainSets指定了训练集的数据选取方式, 其余数据为测试集
        %每行为名称和数据编号
        function [trainData, trainLabel, testData, testLabel] = generateData(obj, trainSet)
            trainIdx = 1;
            testIdx = 1;
            for i = 1: size(trainSet, 1)
                nowName = trainSet{i, 1};
                if ~isKey(obj.name2Label, nowName)
                    continue;
                end
                nowLabel = obj.name2Label(nowName);
                %获取对应类别的数据
                number2Data = obj.label2Data(obj.name2Label(nowName));
                keyNumbers = keys(number2Data);
                trainKeys = trainSet{i, 2};
                for j = 1: length(keyNumbers)
                    nowKey = keyNumbers{1, j};
                    nowData = number2Data(nowKey);
                    [r, c] = size(nowData);
                    if find(trainKeys == nowKey)
                        s = trainIdx;
                        e = trainIdx + r - 1;
                        trainData(s: e, 1: c) = nowData;
                        trainLabel(s: e, 1) = ones(r, 1) * nowLabel;
                        trainIdx = trainIdx + r;
                    else
                        s = testIdx;
                        e = testIdx + r - 1;
                        testData(s: e, 1: c) = nowData;
                        testLabel(s: e, 1) = ones(r, 1) * nowLabel; 
                        testIdx = testIdx + r;
                    end
                end
            end
        end

        %读取data文件中的数据,整理后保存为pdata文件
        function data = readAndWrite(obj, path)
            %读取原始数据
            d = readmatrix(path + "\data.xlsx");
            [r, ~] = size(d);
            if mod(r, obj.dataFrame) ~= 0
                sprintf("数据帧不完整, 请检查后再处理!")
                return;
            end
            %计算新的行数和列数
            row = floor(r / obj.dataFrame);
            %时间 + 温度 + 接收管数目 * 波段数目
            col = 1 + 1 + obj.pNum * obj.rNum;
            data = zeros(row, col);
            T = Time();
            %保存数据
            for i = 1: row
                begin = (i - 1) * obj.dataFrame;
                %保存时间和温度
                data(i, 1) = T.time2Int(T.convertDate(...
                    d(begin + obj.tempRow, obj.timeCol)));
                data(i, 2) = d(begin + obj.tempRow, obj.dataCol);
                %保存电压数据
                for j = 1: obj.rNum
                    for k = 1: obj.pNum
                       %原位置
                       dp = obj.p890 + (k - 1) * obj.rNum + (j - 1);
                       %新位置
                       np = 3 + (j - 1) * obj.pNum + (k - 1);
                       data(i, np) = d(begin + dp, obj.dataCol);
                    end
                end   
            end
            writematrix(data, path + "\pdata.xlsx");
        end

    end
end