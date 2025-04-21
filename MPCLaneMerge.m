clear
close all

config;
LaneMerge = Map('MPCLaneMerge'); % 地図の初期化

MainLane = Lane('MainLane', 0, 1600); % メインレーンの初期化
SubLane = Lane('SubLane', 0, 1000); % サブレーンの初期化

LaneMerge.add_Lane(MainLane); % メインレーンの追加
LaneMerge.add_Lane(SubLane); % サブレーンの追加

% メインレーンの車両を追加
for Vehicle_ID = 1:10
    % 車両をメインレーンに追加
    MainLane.add_Vehicle(Vehicle(Vehicle_ID, 'CAR'), MainLane.end_position - 300 * Vehicle_ID, 0);
end

% サブレーンの車両を追加
for Vehicle_ID = 1:20
    % 車両をサブレーンに追加
    SubLane.add_Vehicle(Vehicle(Vehicle_ID + 100, 'CAR'), SubLane.end_position - 300 * Vehicle_ID, 0);
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

for KK=1:5000
    if(mod(KK,5)==1)
        delete(plt);
        TrafficPlot;
    end

    % メインレーン車両の更新
    mainlane_vehicles = values(MainLane.Vehicles);
    for vehicle = mainlane_vehicles'
        % 車両の前方車両を取得
        lead_vehicle = MainLane.get_lead_vehicle(vehicle.Vehicle_ID);

        % 車両の加速度を計算
        vehicle.IDM(lead_vehicle);

        % 車両の状態を更新
        vehicle.update();

        % 車両の位置が道路の範囲外に出た場合、車両を削除
        if vehicle.position > MainLane.end_position
            MainLane.remove_Vehicle(vehicle.Vehicle_ID);
        end
    end

    % サブレーン車両の更新
    sublane_vehicles = values(SubLane.Vehicles);
    for vehicle = sublane_vehicles'
        % 車両の前方車両を取得
        lead_vehicle = SubLane.get_lead_vehicle(vehicle.Vehicle_ID);

        % 車両の加速度を計算
        vehicle.IDM(lead_vehicle);

        % 車両の状態を更新
        vehicle.update();

        % 車両の位置が道路の範囲外に出た場合、車両を削除
        if vehicle.position > SubLane.end_position
            MainLane.add_Vehicle(vehicle, vehicle.position, vehicle.velocity);
            SubLane.remove_Vehicle(vehicle.Vehicle_ID)
        end
    end

end