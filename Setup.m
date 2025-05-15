clear;
close all;

config;

hFig=figure; set(hFig, 'position', [20,300,1000,200]);
Garea1=[0,X_MAX]; Garea2=[5.5,5.5]+1;
area(Garea1,Garea2, 'FaceColor',[0.65 0.995 0.95]); hold on;

% 結果を保存するフォルダを作成
output_folder = 'result';
if exist(output_folder, 'dir')
    rmdir(output_folder, 's'); % フォルダを削除
end
mkdir(output_folder); % 新しいフォルダを作成

% 動画保存の設定
video_filename = fullfile(output_folder, 'simulation_record.avi');
video_writer = VideoWriter(video_filename);
open(video_writer);

% 道路の描画
xr1=0.:50:450; % 道路位置
yr1=(4-2.8./(1.+exp(-0.02*(xr1-200.0)))); % 道路形状の曲線
plot(xr1,yr1,'LineWidth',10,'Color',[0.7 0.7 0.7]);
plot([0;X_MAX], [1;1],'LineWidth',10,'Color',[0.7 0.7 0.7]);

fm = 1;
plt = [];