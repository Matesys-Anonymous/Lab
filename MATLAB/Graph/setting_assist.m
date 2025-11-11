%% グラフ作成時の設定を管理できるようにするためのコード
% MATLAB R2024bで作成
clear;
close all;
clc;

%% 日付の取得
get_date = datetime;
get_year = year(get_date);
get_month = month(get_date);
get_day = day(get_date);
string(get_year,get_month,get_day);

setting_date = strcat(get_year,'-',get_month,'-',get_day);

% 設定のI/O
% 設定の書き出し
