classdef Lane<handle
    % Lane 車両の走行道路を表すクラス
    properties(GetAccess = 'public', SetAccess = 'private')
        Lane_ID = [] % 道路のID

        WIDTH = [] % 道路の幅

        start_position = [] % 道路の開始位置 (m)
        end_position = [] % 道路の終了位置 (m)

        Vehicles = dictionary % 道路上の車両リスト
    end

    methods

        function obj = Lane(Lane_ID, start_position_m, end_position_m)
            % 道路の初期化
            obj.Lane_ID = Lane_ID;
            obj.WIDTH = 3.5; % 道路の幅 (m)

            % 道路の開始位置と終了位置を設定
            obj.start_position = start_position_m; % 開始位置 (m)
            obj.end_position = end_position_m; % 終了位置 (m)

            % 車両リストを初期化
            obj.Vehicles = dictionary; % 道路上の車両リスト
        end

        function add_Vehicle(obj, Vehicle, init_position_m, init_velocity_m_s)
            % 車両を道路に追加
            obj.Vehicles(Vehicle_ID) = Vehicle;
            Vehicle.Lane_ID = obj.Lane_ID; % 車両の道路IDを設定
            Vehicle.position = init_position_m; % 車両の初期位置を設定
            Vehicle.velocity = init_velocity_m_s; % 車両の初期速度を設定
        end

        function remove_Vehicle(obj, Vehicle_ID)
            % 車両を道路から削除
            if isKey(obj.Vehicles, Vehicle_ID)
                remove(obj.Vehicles, Vehicle_ID);
            else
                error('Vehicle ID not found in the lane!');
            end
        end
    end
end