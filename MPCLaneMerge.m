clear
close all

config;

MainLane = Lane('MainLane', 0, 1600); % メインレーンの初期化
SubLane = Lane('SubLane', 0, 1200); % サブレーンの初期化

% メインレーンの車両を追加
for Vehicle_ID = 1:20
    % 車両をメインレーンに追加
    MainLane.add_Vehicle(Vehicle(Vehicle_ID, 'CAR', 'IDM'), MainLane.end_position - 200 * Vehicle_ID, 0);
end

% サブレーンの車両を追加
for Vehicle_ID = 1:20
    % 車両をサブレーンに追加
    SubLane.add_Vehicle(Vehicle(Vehicle_ID + 100, 'CAR', 'IDM'), SubLane.end_position -200 * Vehicle_ID, 0);
end

hFig=figure; set(hFig, 'position', [20,300,1000,200]);
Garea1=[0,2000]; Garea2=[5.5,5.5]+1;
area(Garea1,Garea2, 'FaceColor',[0.65 0.995 0.95]); hold on;

% 道路の描画
xr1=2.:50:2000; % 道路位置
yr1=(4-3./(1.+exp(-0.02*(xr1-800.0)))); % 道路形状の曲線
plot(xr1,yr1,'LineWidth',10,'Color',[0.7 0.7 0.7]);
plot([5;2000], [1;1],'LineWidth',10,'Color',[0.7 0.7 0.7]);

fm = 1;
plt = [];

for KK=1:500
    if(mod(KK,2)==1)
        delete(plt);
        TrafficPlot;
    end

    % 車両の更新
    UpdateTraffic(MainLane, SubLane)

end