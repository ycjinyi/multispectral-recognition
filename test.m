clc;
clear;
close all;

sets = {"干雪", 1; "明冰", 2; "湿雪", 3};

DM  = DataManagement(sets);
DM.readFile(pwd + "\实验数据");
DM.getNumber("干雪");