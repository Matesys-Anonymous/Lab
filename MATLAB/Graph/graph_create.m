%% MATLAB R2024bで作成
clear;
close all;
clc;
%% 初期設定（基本的に変更するのはここだけ）
% パスの指定(適宜変える、大元の大元くらい)
Drive_letter = 'E';
root = ':\Laboratory\実験データ\実験\生データ\';

% 日付ごとにフォルダを変更する設定
folder_year = '2025';
folder_month = '10';% 1桁の場合は0Xと打つ
folder_day = '10';% 1桁の場合は0Xと打つ
folder_add = '';% 追加データ用、データの欠損なら''と入力(初期値) 例：(DIC)など

% 何Hzのデータか
Hz = '65';

% pngファイル保存先フォルダ指定/将来の機能拡張用(ほとんどコードはある)
path_png = '\png\';

%% 設定の適用
% 拡張子指定
extention_csv = '.csv';
extention_png = '.png';

% CSVファイルのパスの設定
hyphen = '-';
folder_path = strcat(Drive_letter,root,folder_year,hyphen,folder_month,hyphen,folder_day,folder_add);

% グラフの種類（点(十字))
% 点グラフ
graph = 'Pointgraph';
type = 'x';

% グラフ書式設定
FONTSIZE = 16;
FONTNAME = 'Times New Roman';
% 凡例設定
Hz_legend = strcat(Hz,'Hz');
LOCATION = 'northeast';
% グラフのx軸の範囲設定
TimeStart = 0;
TimeEnd = 12;
% 図の位置とサイズの指定
position = [0 0 1000 500];
% ラベル設定
label_x = 'Time [s]';
label_y_mm = 'Displacement [mm]';
label_y_um = 'Displacement [μm]';

%% グラフ化の処理
%CSVデータの読み込み
CSVFILE = [folder_path,'\',Hz,extention_csv];

% CSVファイルからのデータ読み込み
data = readmatrix(CSVFILE);

% データサイズの読み込み
data_size = length(data);

% 時間データの作成
data(1,2)=0.00002;
for t=1:data_size-1
    data(t+1,2)=data(t,2)+0.00002;
end

% 変位の計算(原点を0にするやつ)
for t=1:data_size
    data(t,5)=data(t,3)-data(1,3); % Micrometer
    data(t,6)=data(t,4)-data(1,4); % Millimeter
end

% グラフの軸成分指定
% Time = data(:,2);
% Micrometer = data(:,5);
% Micrometer2Millimeter = data(:,5)*(10^(-3));
% Millimeter = data(:,6);
% Millimeter2Micrometer = data(:,6)*(10^(3));

%% グラフのプロット
% マイクロメートルの変位プロット
figure;
plot(data(:,2),data(:,5))
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlim ([TimeStart TimeEnd]);
xlabel(label_x,'FontSize',FONTSIZE,'FontName',FONTNAME)
ylabel(label_y_um,'FontSize',FONTSIZE,'FontName',FONTNAME)
legend(Hz_legend,'FontSize',FONTSIZE,'Location',LOCATION)
grid('on')

% マイクロメートルをミリメートルに変換した変位プロット
figure;
plot(data(:,2),data(:,5)*(10^(-3)))
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlim ([TimeStart TimeEnd]);
xlabel(label_x,'FontSize',FONTSIZE,'FontName',FONTNAME)
ylabel(label_y_mm,'FontSize',FONTSIZE,'FontName',FONTNAME)
legend(Hz_legend,'FontSize',FONTSIZE,'Location',LOCATION)
grid('on')

% ミリメートルの変位プロット
figure;
plot(data(:,2),data(:,6))
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlim ([TimeStart TimeEnd]);
xlabel(label_x,'FontSize',FONTSIZE,'FontName',FONTNAME)
ylabel(label_y_mm,'FontSize',FONTSIZE,'FontName',FONTNAME)
legend(Hz_legend,'FontSize',FONTSIZE,'Location',LOCATION)
grid('on')

% ミリメートルをマイクロメートルに変換した変位プロット
figure;
plot(data(:,2),data(:,6)*(10^(3)))
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlim ([TimeStart TimeEnd]);
xlabel(label_x,'FontSize',FONTSIZE,'FontName',FONTNAME)
ylabel(label_y_um,'FontSize',FONTSIZE,'FontName',FONTNAME)
legend(Hz_legend,'FontSize',FONTSIZE,'Location',LOCATION)
grid('on')

%% 画像の保存
%{
% ファイル名指定
filename_png = [Hz,extention_png];

% pngデータ保存
saveas(fig,filename_png)
%}