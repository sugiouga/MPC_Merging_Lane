classdef Lane<handle
    % Lane 車両の走行道路を表すクラス
    properties(GetAccess = 'public', SetAccess = 'private')
        Lane_ID = [] % 道路のID
        WIDTH = [] % 道路の幅
        REFERENCE_VELOCITY = [] % 参照速度 (m/s)

        start_position = [] % 道路の開始位置 (m)
        end_position = [] % 道路の終了位置 (m)

        Vehicles = [] % 道路上の車両リスト
    end

    methods

        function obj = Lane(Lane_ID, start_position_m, end_position_m, REFERENCE_VELOCITY_m_s)
            % 道路の初期化
            obj.Lane_ID = Lane_ID;
            obj.WIDTH = 3.5; % 道路の幅 (m)
            obj.REFERENCE_VELOCITY = REFERENCE_VELOCITY_m_s; % 参照速度 (m/s)

            % 道路の開始位置と終了位置を設定
            obj.start_position = start_position_m; % 開始位置 (m)
            obj.end_position = end_position_m; % 終了位置 (m)

            % 車両リストを初期化
            obj.Vehicles = dictionary; % 道路上の車両リスト
        end

        function add_Vehicle(obj, Vehicle, init_position_m, init_velocity_m_s)
            % 車両の初期位置と速度を設定
            Vehicle.set_Lane_ID(obj.Lane_ID); % メソッドを呼び出してレーンIDを設定
            Vehicle.set_init_position(init_position_m); % メソッドを呼び出して初期位置を設定
            Vehicle.set_init_velocity(init_velocity_m_s); % メソッドを呼び出して初期速度を設定
            Vehicle.set_reference_velocity(obj.REFERENCE_VELOCITY); % メソッドを呼び出して参照速度を設定

            % 車両を道路に追加
            obj.Vehicles(Vehicle.Vehicle_ID) = Vehicle;
        end

        function remove_Vehicle(obj, Vehicle_ID)
            % 車両を道路から削除
            if isKey(obj.Vehicles, Vehicle_ID)
                obj.Vehicles = remove(obj.Vehicles, Vehicle_ID);
            else
                error('Vehicle ID not found in the lane!');
            end
        end

        function lead_vehicle = get_lead_vehicle(obj, position_m)
            % 車両の最も近い先行車両を取得
            lead_vehicle = []; % 前方車両の初期化
            min_distance = inf; % 最小距離の初期化

            % 前方車両を検索
            keys = obj.Vehicles.keys;
            for i = 1:length(keys)
                other_vehicle = obj.Vehicles(keys(i));
                if other_vehicle.position > position_m
                    distance = other_vehicle.position - position_m;
                    if distance < min_distance
                        min_distance = distance;
                        lead_vehicle = other_vehicle; % 最も近い前方車両を設定
                    end
                end
            end
        end

        function follow_vehicle = get_follow_vehicle(obj, position_m)
            % 車両の最も近い後続車両を取得
            follow_vehicle = []; % 後続車両の初期化
            min_distance = inf; % 最小距離の初期化

            % 後続車両を検索
            keys = obj.Vehicles.keys;
            for i = 1:length(keys)
                other_vehicle = obj.Vehicles(keys(i));
                if other_vehicle.position < position_m
                    distance =  position_m - other_vehicle.position;
                    if distance < min_distance
                        min_distance = distance;
                        follow_vehicle = other_vehicle; % 最も近い後続車両を設定
                    end
                end
            end
        end

    end
end