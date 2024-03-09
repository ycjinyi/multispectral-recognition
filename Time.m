classdef Time
    %此函数用于时间的转换
    
    properties
        
    end
    
    methods
        function obj = Time()
            %时间类的空构造函数
        end
        
        function dateStr = convertDate(~, time)
            %1685085931 -> 从1970年1月1日起到现在经过的秒数
            %转换为对应的时间字符串
            date = datetime(time, 'ConvertFrom', 'posixtime', 'TimeZone','Asia/Hong_Kong'); %datetime类型
            dateStr = datestr(date, 'yyyy-mm-dd-HH-MM-SS'); %转换成字符串
        end
        
        %将时间字符串转换为对应的数字 12-13-02 -> 43982 还支持'2023/03/08-18:16:14.114'格式
        function ret = time2Int(~, time) %不管年月日，只计算时分秒对应的数值
            if size(time, 2) == size('2023/03/08-18:16:14.114', 2)
                hour   = str2double(time(1, 12: 13));
                minute = str2double(time(1, 15: 16));
                second = str2double(time(1, 18: 19));
            elseif size(time, 2) == size('2023-05-26-15-21-11', 2)
                hour   = str2double(time(1, 12: 13));
                minute = str2double(time(1, 15: 16));
                second = str2double(time(1, 18: 19));
            elseif size(time, 2) == size('12-13-02', 2)
                hour   = str2double(time(1, 1: 2));
                minute = str2double(time(1, 4: 5));
                second = str2double(time(1, 7: 8));
            else
                ret = 0;
                return;
            end
            ret =  hour * 3600 ...
                +  minute * 60 ...
                +  second;
        end
        
        %将数字转换为对应的时间字符串 43982 -> 12-13-02
        function ret = int2Time(obj, time)
            second = obj.addZero(mod(time, 60));
            time = floor(time / 60);
            minute = obj.addZero(num2str(mod(time, 60)));
            hour = obj.addZero(num2str(floor(time / 60)));
            ret = strcat(hour, "-", minute, "-", second);
        end
        
        %将数字转换为字符串时，补零 2 -> 02
        function ret = addZero(~, time)
            if time < 10
                ret = strcat("0", num2str(time));
            else 
                ret = num2str(time);
            end
        end
        
    end
end

