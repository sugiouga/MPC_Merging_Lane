classdef Road<handle
    % Road 車両の走行道路を表すクラス
    properties(GetAccess = 'public', SetAccess = 'private')

        Road_ID = [] % 道路のID

        Lane_Number = [] % 車線数
        WIDTH = [] % 道路の幅

        start_position = [] % 道路の開始位置 (m)
        end_position = [] % 道路の終了位置 (m)

        Vehicles = dictionary % 道路上の車両リスト
    end

    methods

        function obj = Road(Road_ID, Lane_Number, start_position_m, end_position_m)
            % 道路の初期化
            obj.Road_ID = Road_ID;
            obj.WIDTH = 3.5 * Lane_Number; % 道路の幅 (m)

            % 道路の開始位置と終了位置を設定
            obj.start_position = start_position_m; % 開始位置 (m)
            obj.end_position = end_position_m; % 終了位置 (m)

            % 車両リストを初期化
            obj.Vehicles = dictionary; % 道路上の車両リスト
        end

        function add_Vehicle(obj, Vehicle)
            % 車両を道路に追加
            obj.Vehicles(Vehicle_ID) = Vehicle;
            Vehicle.Road_ID; % 車両の道路IDを設定
        end

        function remove_Vehicle(obj, Vehicle_ID)
            % 車両を道路から削除
            if isKey(obj.Vehicles, Vehicle_ID)
                remove(obj.Vehicles, Vehicle_ID);
            else
                error('Vehicle ID not found in the road!');
            end
        end
    end
end