classdef Vehicle<handle
    % Vehicle 車両の基本クラス
    properties(GetAccess = 'public', SetAccess = 'private')
        % 車両の基本情報
        Vehicle_ID = [] % 車両のID
        Lane_ID = [] % 車両が走行している道路のID
        TIME_STEP = [] % 時間刻み
        PREDICTION_HORIZON = [] % 予測ホライズン

        Vehicle_TYPE = [] % 車両の種類
        LENGTH = [] % 車両の長さ
        WIDTH = [] % 車両の幅

        position = [] % 現在位置
        velocity = [] % 現在速度
        acceleration = [] % 現在加速度
        jerk = [] % 現在ジャーク

        Vehicle_Controller = [] % 車両の制御器
        input = [] % 入力は加速度

        REFERENCE_VELOCITY = [] % 参照速度 (m/s)
        MIN_VELOCITY = [] % 車両の最小速度
        MAX_VELOCITY = [] % 車両の最大速度
        MIN_ACCELERATION = [] % 車両の最小加速度
        MAX_ACCELERATION = [] % 車両の最大加速度
    end

    methods

        function obj = Vehicle(Vehicle_ID, Vehicle_TYPE)
            config; % config.mを読み込む
            % 車両の初期化
            obj.Vehicle_ID = Vehicle_ID;
            obj.Lane_ID = 0;
            obj.Vehicle_TYPE = Vehicle_TYPE;
            obj.TIME_STEP = TIME_STEP;
            obj.PREDICTION_HORIZON = PREDICTION_HORIZON;

            % 初期状態を設定
            obj.position = 0; % 現在位置
            obj.velocity = 0; % 現在速度
            obj.acceleration = 0; % 現在加速度
            obj.jerk = 0; % 現在ジャーク

            obj.input = 0; % 入力は加速度

            % 車両の長さと幅を設定
            switch Vehicle_TYPE
                case 'CAR'
                    obj.LENGTH = 5.25; % 車両の長さ
                    obj.WIDTH = 1.69; % 車両の幅
                case 'TRUCK'
                    obj.LENGTH = 12; % 車両の長さ
                    obj.WIDTH = 2.5; % 車両の幅
                otherwise
                    error('Unknown Vehicle Type!');
            end

            % 車両の速度と加速度を設定
            obj.REFERENCE_VELOCITY = 25; % 参照速度 (m/s)
            obj.MIN_VELOCITY = 0; % 車両の最小速度 (m/s)
            obj.MAX_VELOCITY = 30; % 車両の最大速度 (m/s)
            obj.MIN_ACCELERATION = -30; % 車両の最小加速度 (m/s^2)
            obj.MAX_ACCELERATION = 20; % 車両の最大加速度 (m/s^2)
        end

        function set_Lane_ID(obj, Lane_ID)
            % 車両の走行している道路を設定する
            obj.Lane_ID = Lane_ID;
        end

        function set_init_position(obj, init_position_m)
            % 車両の初期位置を設定する
            obj.position = init_position_m;
        end

        function set_init_velocity(obj, init_velocity_m_s)
            % 車両の初期速度を設定する
            obj.velocity = init_velocity_m_s;
        end

        function set_reference_velocity(obj, reference_velocity_m_s)
            % 車両の参照速度を設定する
            obj.REFERENCE_VELOCITY = reference_velocity_m_s;
        end

        function update(obj)

            % 車両の加速度入力を制限する
            if obj.input < obj.MIN_ACCELERATION
                obj.input = obj.MIN_ACCELERATION;
            elseif obj.input > obj.MAX_ACCELERATION
                obj.input = obj.MAX_ACCELERATION;
            end

            % ジャークを計算する
            obj.jerk = (obj.acceleration - obj.input) / obj.TIME_STEP;

            % 加速度入力を受け取る
            obj.acceleration = obj.input;

            % 車両の位置･速度を更新する
            obj.position = obj.position + obj.velocity * obj.TIME_STEP + 0.5 * obj.acceleration * (obj.TIME_STEP ^ 2);
            obj.velocity = obj.velocity + obj.acceleration * obj.TIME_STEP;

            % 車両の位置･速度を制限する
            if obj.velocity < obj.MIN_VELOCITY
                obj.velocity = obj.MIN_VELOCITY;
            elseif obj.velocity > obj.MAX_VELOCITY
                obj.velocity = obj.MAX_VELOCITY;
            end
        end

        function constant_speed(obj)
            if obj.velocity == obj.REFERENCE_VELOCITY
                obj.input = 0; % 車両の加速度を0に設定
            else
                obj.input = (obj.REFERENCE_VELOCITY - obj.velocity) / obj.TIME_STEP; % 目標速度に向かう加速度
            end
        end

        function IDM(obj, lead_vehicle)
            % Intelligent Driver Model (IDM)を使用して車両の加速度を計算する
            % lead_vehicle: 前方車両のオブジェクト
            % 車両の加速度を計算する
            if isempty(lead_vehicle)
                obj.input = (obj.REFERENCE_VELOCITY - obj.velocity) / obj.TIME_STEP; % 目標速度に向かう加速度
            else
                % 車間距離と相対速度を計算する
                distance = lead_vehicle.position - obj.position - lead_vehicle.LENGTH; % 車間距離 (m)
                relative_velocity = obj.velocity - lead_vehicle.velocity; % 相対速度 (m/s)

                % IDMの式を使用して加速度を計算する
                min_distance = 1.5; % 最小車間距離 (m)
                desired_time_headway = 1.3; % 目標時間間隔 (s)
                max_acceleration = obj.MAX_ACCELERATION; % 最大加速度 (m/s^2)
                comfortable_deceleration = 2.5; % 快適減速度 (m/s^2)

                % 車間距離の目標値 (m)
                s_star = min_distance + obj.velocity * desired_time_headway + ...
                         (obj.velocity * relative_velocity) / (2 * sqrt(max_acceleration * comfortable_deceleration));

                % IDMの加速度計算式
                obj.input = max_acceleration * (1 - (obj.velocity / obj.REFERENCE_VELOCITY)^4 - (s_star / distance)^2);
            end
        end

        function simpleMPC(obj, lead_vehicle, follow_vehicle, end_position)
            % MPCを使用して車両の加速度を計算する
            % 状態は[位置, 速度]
            % 入力は加速度
            % x(k)=[位置，速度，加速度]'
            % x=[x(N),...,x(k+1),x(k),...,x(0)]'

            if isempty(follow_vehicle)
                obj.IDM(lead_vehicle); % IDMを使用して加速度を計算
                return;
            end

            % 初期解を設定する
            u0 = zeros(obj.PREDICTION_HORIZON, 1);

            % 解の下限lbと上限ubを設定する
            lb = [repmat(obj.MIN_ACCELERATION, obj.PREDICTION_HORIZON, 1)];
            ub = [repmat(obj.MAX_ACCELERATION, obj.PREDICTION_HORIZON, 1)];

            % 周囲の車両の状態を予測する
            lead_vehicle_status = predict_surround_vehicle_status(lead_vehicle, obj.PREDICTION_HORIZON, obj.TIME_STEP); % 前方車両の状態を予測する
            follow_vehicle_status = predict_surround_vehicle_status(follow_vehicle, obj.PREDICTION_HORIZON, obj.TIME_STEP); % 後方車両の状態を予測する

            % 不等式制約を設定する
            init_ego_vehicle_status = [obj.position; obj.velocity]; % ホスト車両の状態
            F_matrix = get_F_matrix(obj.PREDICTION_HORIZON, obj.TIME_STEP); % F行列を取得
            G_matrix = get_G_matrix(obj.PREDICTION_HORIZON, obj.TIME_STEP); % G行列を取得
            A = [G_matrix; -G_matrix];
            b = [lead_vehicle_status - F_matrix*init_ego_vehicle_status; -follow_vehicle_status + F_matrix*init_ego_vehicle_status]; % 不等式制約

            % エゴ車両の目標状態を設定する
            ratio = 0.8;
            reference_status = (1-ratio)*lead_vehicle_status + ratio*follow_vehicle_status;

            % 評価関数を設定する
            weight = 1; % 重み
            fun = @(u) weight * sum((F_matrix*init_ego_vehicle_status + G_matrix*u - reference_status).^2); % 評価関数)

            % 最適化問題を解く
            u = fmincon(fun, u0, A, b, [], [], lb, ub);

            % 入力を更新する
            obj.input = u(1); % 最適化された加速度を入力に設定
        end
    end
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

function status = predict_surround_vehicle_status(vehicle, N, h)
    % 車両の状態を予測する
    % x(k)=[位置，速度]'
    % x(k+1) = Ax(k) + Bu(k)
    % X = [x1,x2,...,xN]'
    % X = Fx0 + GU

    x0 = [vehicle.position; vehicle.velocity]; % 車両の初期状態
    F_matrix = get_F_matrix(N, h); % F行列を取得
    status = F_matrix*x0; % 車両の状態を予測する
end