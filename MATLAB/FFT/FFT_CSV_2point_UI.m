%% 注意事項 
% MATLAB R2024bで作成しました。
% 2024bより新しいMATLABで編集を行わないで下さい。やったら許しません。
% ペルソナ・ノン・グラータとして国外追放も辞さない考えです。
% 編集を阻害するものではありませんが2024bで開けなくなった瞬間にペルソナ・ノン・グラータに認定します。

%% 皆さん大好きおまじない
clear; clc; close all;

%% 設定(基本的にここだけいじればおーけー)
% FFTのデータのパスを簡単に書き換えられるようにする設定
% FFT_data_path = 'E:\Laboratory\実験データ\実験\生データ\2025-10-09\74.csv';
FFT_data_path = 'FFT_data.xlsx';

%% グラフ書式設定
% フォントの大きさが変わるよ
FONTSIZE = 16;
% フォントが変わるよ
FONTNAME = 'Times New Roman';

%% データ読み込み
data = readmatrix(FFT_data_path);

%% プロンプト用のコード
% データ種類の判別
x = data(1,1);
if x == 600000
    Data_discrimination = 0;
else
    Data_discrimination = 1;
end

% 読み込む変位データの列の設定の入力
prompt = "読み込む変位データの列は？\n";
x = input(prompt);
Displacement_row = x; % xlsxなら1/csvなら3または4が一般的

% 単位変換用の設定の入力
prompt = "単位変換用の設定は？(0→設定の無視/1→μmにする/2→mmにする)\n";
x = input(prompt);
Unit_exchange = x; % 0→設定の無視/1→μmに統一/2→mmに統一

% DRとUEの競合確認
if Data_discrimination == 0 && Displacement_row == 3 && Unit_exchange == 1 || Data_discrimination == 0 && Displacement_row == 4 && Unit_exchange == 2
    fprintf(['「読み込む変位データの列は？」と「単位変換用の設定は？」の設定に競合が検出されました。\n' ...
        '誤検出の場合はこのまま実行してください。\n']);
    prompt = "このまま実行しますか？ Y/N [Y]: ";
    UR_DE_competition = input(prompt,"s");
    if isempty(UR_DE_competition)
        UR_DE_competition = 'Y';
    end
    if strcmp(UR_DE_competition, 'N')|strcmp(UR_DE_competition, 'n')
        fprintf('「読み込む変位データの列は？」と「単位変換用の設定は？」の設定を確認してください。このコードは停止されます。\n');
        return;
    end
end

% サンプリング周波数の打ち込み設定の入力
prompt = "サンプリング周波数の打ち込み設定は？(0→自動/1→手動/2→実験モード(600000/12))\n";
x = input(prompt);
Fs_setting_pram = x;

if Fs_setting_pram == 0
    % データの個数の入力
    prompt = "データの個数は？(解析→いくつだろう？・実験→600000(0が5つ))\n";
    x = input(prompt);
    Data_number = x;
    % 時間の入力
    prompt = "全体の時間は？(解析→解析時間・実験→12)\n";
    x = input(prompt);
    Time = x;
    Fs_setting = Data_number/Time;
elseif Fs_setting_pram == 1
    prompt = "サンプリング周波数は？\n";
    x = input(prompt);
    Fs_hand_setting = x;
    Fs_setting = Fs_hand_setting;
elseif Fs_setting_pram == 2
    Data_number = 600000;
    Time = 12;
    Fs_setting = Data_number/Time;
else
    fprintf('「サンプリング周波数の打ち込み設定は？」に入力した数値を確認してください。このコードは停止されます。\n');
    return;
end

%% パラメータ設定
Fs = Fs_setting;  % サンプリング周波数 [Hz]
dt = 1 / Fs;

%% 変位データ読み込み
x = data(:,Displacement_row);  % A列の変位データ
% 単位変換
if Unit_exchange == 0
    x_exchange = x;
elseif Unit_exchange == 1
    x_exchange = x*(10^3);
elseif Unit_exchange == 2
    x_exchange = x*(10^(-3));
else
    fprintf('Unit_exchangeの数値を確認してください。このコードは単位変換は行われずに続行されます。\n');
    x_exchange = x; % 単位変換を行わずに続行
end

N = length(x);           % データ点数
t = (0:N-1) * dt;        % 時間ベクトル（参考用）

%% FFTの実行
Y = fft(x_exchange);               % 高速フーリエ変換
P2 = abs(Y / N);          % 両側振幅スペクトル
P1 = P2(1:N/2+1);         % 片側振幅スペクトル
P1(2:end-1) = 2 * P1(2:end-1);

f = Fs * (0:(N/2)) / N;   % 周波数軸

%% オプション：ピーク検出
[peakVal, peakIdx] = max(P1);
fprintf('最大振幅周波数 = %.2f Hz（振幅 %.4f）\n', f(peakIdx), peakVal);

%% グラフの範囲を美しくするための設定
beautiful_graph = fix((f(peakIdx)/100)+1)*100;

%% 結果のプロット(全体)
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
grid on;

%% 結果のプロット(ピーク検出を元に(誤差あるかも))
% 最高のピーク値が最も右に来ていなければ誤差が出る。直す気になったまたは直せとの世論が高まったら直す。
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
xlim ([0, beautiful_graph]);
grid on;

%% 結果のプロット(ピーク検出を元に(誤差直ってるかも))
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
xlim ([0, beautiful_graph+100]);
grid on;

%% 結果のプロット(ピーク検出を元に(自動でダメなら最後は人力！))
% xlimの値をいじいじしてください。
% まとめてコメントアウトしてあります。「%{」と「%}」を削除して実行してください。
%{
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
% xlim ([0, 300]);
grid on;
%}