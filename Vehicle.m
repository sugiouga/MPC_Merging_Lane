classdef Vehicle<handle
    % Vehicle 車両の基本クラス
    properties(GetAccess = 'public', SetAccess = 'private')
        % 車両の基本情報
        Vehicle_ID = [] % 車両のID
        Lane_ID = [] % 車両が走行している道路のID
        TIME_STEP = [] % 時間刻み

        Vehicle_TYPE = [] % 車両の種類
        LENGTH = [] % 車両の長さ
        WIDTH = [] % 車両の幅

        position = [] % 現在位置
        velocity = [] % 現在速度
        acceleration = [] % 現在加速度
        jerk = [] % 現在ジャーク

        Controller = [] % 車両の制御器
        input = [] % 入力は加速度

        MIN_VELOCITY = [] % 車両の最小速度
        MAX_VELOCITY = [] % 車両の最大速度
        MIN_ACCELERATION = [] % 車両の最小加速度
        MAX_ACCELERATION = [] % 車両の最大加速度
    end

    methods

        function obj = Vehicle(Vehicle_ID, Vehicle_TYPE, Controller)
            config; % config.mを読み込む
            % 車両の初期化
            obj.Vehicle_ID = Vehicle_ID;
            obj.Lane_ID = 0;
            obj.Vehicle_TYPE = Vehicle_TYPE;
            obj.TIME_STEP = TIME_STEP;

            % 初期状態を設定
            obj.position = 0; % 現在位置
            obj.velocity = 0; % 現在速度
            obj.acceleration = 0; % 現在加速度
            obj.jerk = 0; % 現在ジャーク

            obj.Controller = Controller; % 車両の制御器
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
            obj.MIN_VELOCITY = 0; % 車両の最小速度 (m/s)
            obj.MAX_VELOCITY = 30; % 車両の最大速度 (m/s)
            obj.MIN_ACCELERATION = -3; % 車両の最小加速度 (m/s^2)
            obj.MAX_ACCELERATION = 2; % 車両の最大加速度 (m/s^2)
        end

        function set_init_position(obj, init_position_m)
            % 車両の初期位置を設定する
            obj.position = init_position_m;
        end

        function set_init_velocity(obj, init_velocity_m_s)
            % 車両の初期速度を設定する
            obj.velocity = init_velocity_m_s;
        end

        function set_Lane_ID(obj, Lane_ID)
            % 車両の走行している道路を設定する
            obj.Lane_ID = Lane_ID;
        end

        function set_Controller(obj, Controller)
            % 車両の制御器を設定する
            obj.Controller = Controller;
        end


        function update(obj)
            % 制御器から加速度入力を受け取る
            if ~isempty(obj.Controller)
                obj.input = obj.Controller;
            end

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
    end
end