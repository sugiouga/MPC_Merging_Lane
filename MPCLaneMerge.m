Setup;

LaneMerge = Map('MPCLaneMerge'); % 地図の初期化

MainLine = Lane('MainLine', 0, X_MAX, 20); % 本線の初期化
OnRamp = Lane('OnRamp', 0, MERGE_POSITION, 20); % 合流車線の初期化

LaneMerge.add_Lane(MainLine); % 本線の追加
LaneMerge.add_Lane(OnRamp); % 合流車線の追加

% 本線の車両を追加
for id = 1:16
    MainLine_Vehicle_Distance = 60; % 車両間隔 (m)
    MainLine_Vehicle_Velocity = MainLine.REFERENCE_VELOCITY; % 車両速度 (m/s)
    % 車両を本線に追加
    MainLine.add_Vehicle(Vehicle(sprintf('MainLine_Vehicle_%d', id), 'CAR'), MainLine.END_POSITION - MainLine_Vehicle_Distance*(id - 1), MainLine_Vehicle_Velocity);
end

% 合流車線の車両を追加
for id = 1:1
    OnRamp_Vehicle_Distance = 100; % 車両間隔 (m)
    OnRamp_Vehicle_Velocity = OnRamp.REFERENCE_VELOCITY; % 車両速度 (m/s)
    % 車両を合流車線に追加
    OnRamp.add_Vehicle(Vehicle(sprintf('OnRamp_Vehicle_%d', id), 'CAR'), - OnRamp_Vehicle_Distance*(id - 1), OnRamp_Vehicle_Velocity);
end

% シミュレーション時間のループ
for step = 1 : 300

    time = step * TIME_STEP; % 現在の時間

    % 描写の更新
    if(mod(10*time, 10*VIDEO_UPDATE_INTERVAL) == 0)
        delete(plt);
        PlotTraffic;

        % フレームを動画に追加
        frame = getframe(hFig);
        writeVideo(video_writer, frame);
    end

    %各車両の更新
    % 本線車両の更新
    mainline_vehicles = values(MainLine.Vehicles);
    for mainline_vehicle = mainline_vehicles'

        if(mod(10*time, 10*INPUT_UPDATE_INTERVAL) == 0)
            save_vehicle_state_to_csv(mainline_vehicle, time, output_folder);

            if contains(mainline_vehicle.VEHICLE_ID, 'MainLine')
                mainline_vehicle.constant_speed()

                % lead_vehicle_in_MainLine = MainLine.get_lead_vehicle(mainline_vehicle.position);
                % mainline_vehicle.idm(lead_vehicle_in_MainLine);
            elseif contains(mainline_vehicle.VEHICLE_ID, 'OnRamp')
                lead_vehicle_in_MainLine = MainLine.get_lead_vehicle(mainline_vehicle.position);
                follow_vehicle_in_MainLine = MainLine.get_follow_vehicle(mainline_vehicle.position);
                mainline_vehicle.mpc(lead_vehicle_in_MainLine, follow_vehicle_in_MainLine);
            end
        end

        mainline_vehicle.update();

    end

    % 合流車線車両の更新
    onramp_vehicles = values(OnRamp.Vehicles);
    for onramp_vehicle = onramp_vehicles'

        if(mod(10*time, 10*INPUT_UPDATE_INTERVAL) == 0)
            save_vehicle_state_to_csv(onramp_vehicle, time, output_folder);

            if onramp_vehicle.position > 0
                lead_vehicle_in_MainLine = MainLine.get_lead_vehicle(onramp_vehicle.position);
                follow_vehicle_in_MainLine = MainLine.get_follow_vehicle(onramp_vehicle.position);
                onramp_vehicle.mpc(lead_vehicle_in_MainLine, follow_vehicle_in_MainLine);
            else
                lead_vehicle_in_OnLamp = OnRamp.get_lead_vehicle(onramp_vehicle.position);
                onramp_vehicle.idm(lead_vehicle_in_OnLamp);
            end
        end

        onramp_vehicle.update();

        if onramp_vehicle.position > MERGE_POSITION
            MainLine.add_Vehicle(vehicle, vehicle.position, vehicle.velocity);
            OnRamp.remove_Vehicle(vehicle.VEHICLE_ID);
        end
    end

    if isempty(mainline_vehicles) && isempty(onramp_vehicles)
        break;
    end

end

% 動画保存を終了
close(video_writer);
close all;
PlotVehicleData;

function save_vehicle_state_to_csv(Vehicle, time, output_folder)
    % ビークルの状態をCSVファイルに保存する
    filename = fullfile(output_folder, sprintf('%s.csv', Vehicle.VEHICLE_ID));

    % ビークルの状態を取得
    data = [time, Vehicle.position, Vehicle.velocity, Vehicle.acceleration, Vehicle.jerk];

    % ヘッダーを追加 (ファイルが存在しない場合のみ)
    if ~isfile(filename)
        header = {'Time', 'Position', 'Velocity', 'Acceleration', 'Jerk'};
        writecell(header, filename);
    end

    % データを追記
    writematrix(data, filename, 'WriteMode', 'append');
end

%N = PREDICTION_HORIZON; % 予測ホライズン
%h = TIME_STEP; % タイムステップ (s)
function F_matrix = get_F_matrix(N, h)
    % x(k+1) = Ax(k) + Bu(k)
    % X = [x1,x2,...xN]'
    % X = Fx0 + GU
    A_matrix = [1 h;
                0 1];

    F_matrix = zeros(2*N, 2);
    for k = 1:N
        F_matrix(2*k-1:2*k, 1:2) = A_matrix^k;
    end
end

function G_matrix = get_G_matrix(N, h)
    % x(k+1) = Ax(k) + Bu(k)
    % X = [x1,x2,...xN]'
    % X = Fx0 + GU
    A_matrix = [1 h;
                0 1];
    B_matrix = [0.5*h^2;
                h];
    G_matrix = zeros(2*N, N);

    for i = 1:N
        for j = 1:i
            G_matrix(2*i-1:2*i, j) = (A_matrix^(i-j)) * B_matrix;
        end
    end
end

function status = predict_vehicle_status(vehicle, N, h)
    % 車両の状態を予測する
    % x(k)=[位置，速度]'
    % x(k+1) = Ax(k) + Bu(k)
    % X = [x1,x2,...,xN]'
    % X = Fx0 + GU

    x0 = [vehicle.position; vehicle.velocity]; % 車両の初期状態
    F_matrix = get_F_matrix(N, h); % F行列を取得
    status = F_matrix*x0; % 車両の状態を予測する
end
