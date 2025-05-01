classdef Map<handle

    properties(GetAccess = 'public', SetAccess = 'private')
        % Map 地図情報を表すクラス
        Map_ID = [] % 地図のID
        Lanes = [] % 道路リスト
    end

    methods

        function obj = Map(Map_ID)
            % 地図の初期化
            obj.Map_ID = Map_ID;
            obj.Lanes = dictionary; % 道路リスト
        end

        function add_Lane(obj, Lane)
            % 道路を地図に追加
            obj.Lanes(Lane.Lane_ID) = Lane; % 道路を地図に追加
        end

    end
end