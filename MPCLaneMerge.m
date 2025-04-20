clear
close all

config;

MainLane = Lane('MainLane', 0, 1600); % メインレーンの初期化
SubLane = Lane('SubLane', 0, 1600); % サブレーンの初期化

% メインレーンの車両を追加
for Vehicle_ID = 1:20
    % 車両をメインレーンに追加
    MainLane.add_Vehicle(Vehicle(Vehicle_ID, 'CAR', 'IDM'), MainLane.end_position - 100 * Vehicle_ID, 0);
end

% サブレーンの車両を追加
for Vehicle_ID = 1:20
    % 車両をサブレーンに追加
    SubLane.add_Vehicle(Vehicle(Vehicle_ID + 20, 'CAR', 'IDM'), SubLane.end_position -100 * Vehicle_ID, 0);
end