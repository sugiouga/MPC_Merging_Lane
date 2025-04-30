clear
close all

config;
LaneMerge = Map('MPCLaneMerge'); % 地図の初期化

MainLane = Lane('MainLane', 0, 1600, 25); % メインレーンの初期化
SubLane = Lane('SubLane', 0, 1000, 20); % サブレーンの初期化
TerminalLane = Lane('TerminalLane', 1600, 10000, 25); % ターミナルレーンの初期化

LaneMerge.add_Lane(MainLane); % メインレーンの追加
LaneMerge.add_Lane(SubLane); % サブレーンの追加
LaneMerge.add_Lane(TerminalLane); % ターミナルレーンの追加

% メインレーンの車両を追加
for Vehicle_ID = 1:5
    % 車両をメインレーンに追加
    MainLane.add_Vehicle(Vehicle(Vehicle_ID, 'CAR'), 800 - 150 * Vehicle_ID, 25);
end

% サブレーンの車両を追加
for Vehicle_ID = 1:1
    % 車両をサブレーンに追加
    SubLane.add_Vehicle(Vehicle(Vehicle_ID + 100, 'CAR'), 600 -100 * Vehicle_ID, 20);
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

% 結果を保存するフォルダを作成
output_folder = 'result';
if exist(output_folder, 'dir')
    rmdir(output_folder, 's'); % フォルダを削除
end
mkdir(output_folder); % 新しいフォルダを作成

% シミュレーション時間のループ
for step = 1 : 10000
    if(mod(step, 4)==1)
        delete(plt);
        TrafficPlot;
    end

    time = step * TIME_STEP; % 現在の時間

    % メインレーン車両の更新
    mainlane_vehicles = values(MainLane.Vehicles);
    for vehicle = mainlane_vehicles'
        % ビークルの状態をCSVに保存
        save_vehicle_state_to_csv(vehicle, time, output_folder);

        if vehicle.Vehicle_ID > 100 && vehicle.position < 1000
            lead_vehicle_in_MainLane = MainLane.get_lead_vehicle(vehicle.position);
            follow_vehicle_in_MainLane = MainLane.get_follow_vehicle(vehicle.position);
            vehicle.MPC(lead_vehicle_in_MainLane, follow_vehicle_in_MainLane, SubLane.end_position);
        else
            lead_vehicle_in_MainLane = MainLane.get_lead_vehicle(vehicle.position);
            vehicle.constant_speed();
        end

        vehicle.update();

        if vehicle.position > MainLane.end_position
            MainLane.remove_Vehicle(vehicle.Vehicle_ID);
            TerminalLane.add_Vehicle(vehicle, vehicle.position, vehicle.velocity);
        end
    end

    % サブレーン車両の更新
    sublane_vehicles = values(SubLane.Vehicles);
    for vehicle = sublane_vehicles'
        % ビークルの状態をCSVに保存
        save_vehicle_state_to_csv(vehicle, time, output_folder);

        if vehicle.position > 600
            lead_vehicle_in_MainLane = MainLane.get_lead_vehicle(vehicle.position);
            follow_vehicle_in_MainLane = MainLane.get_follow_vehicle(vehicle.position);
            vehicle.MPC(lead_vehicle_in_MainLane, follow_vehicle_in_MainLane, MainLane.end_position);
        else
            lead_vehicle_in_SubLane = SubLane.get_lead_vehicle(vehicle.position);
            vehicle.IDM(lead_vehicle_in_SubLane);
        end

        vehicle.update();

        if vehicle.position > 900
            MainLane.add_Vehicle(vehicle, vehicle.position, vehicle.velocity);
            SubLane.remove_Vehicle(vehicle.Vehicle_ID);
        end
    end

    % 終端レーン車両の更新
    terminallane_vehicles = values(TerminalLane.Vehicles);
    for vehicle = terminallane_vehicles'
        % ビークルの状態をCSVに保存
        save_vehicle_state_to_csv(vehicle, time, output_folder);

        vehicle.update();
    end

    if isempty(mainlane_vehicles) && isempty(sublane_vehicles)
        break;
    end
end

close all;

function save_vehicle_state_to_csv(Vehicle, time, output_folder)
    % ビークルの状態をCSVファイルに保存する
    filename = fullfile(output_folder, sprintf('vehicle_%d.csv', Vehicle.Vehicle_ID));

    % ビークルの状態を取得
    data = [time, Vehicle.position, Vehicle.velocity, Vehicle.acceleration, Vehicle.jerk, Vehicle.Follow_Vehicle_ID, Vehicle.Lead_Vehicle_ID, Vehicle.status];

    % ヘッダーを追加 (ファイルが存在しない場合のみ)
    if ~isfile(filename)
        header = {'Time', 'Position', 'Velocity', 'Acceleration', 'Jerk', 'Follow_Vehicle_ID', 'Lead_Vehicle_ID', 'Status'};
        writecell(header, filename);
    end

    % データを追記
    writematrix(data, filename, 'WriteMode', 'append');
end