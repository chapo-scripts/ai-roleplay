TextFlags = {
    list = {
        {
            flag = 'id',
            fn = function() return tostring(Utils.myid()) end,
            description = 'ID Вашего персонажа'
        },
        {
            flag = 'name',
            fn = function() return sampGetPlayerNickname(Utils.myid()) end,
            description = 'Ник Вашего персонажа'
        },
        {
            flag = 'lvl',
            fn = function() return sampGetPlayerScore(Utils.myid()) end,
            description = 'Уровень Вашего персонажа'
        },
        {
            flag = 'weapon',
            fn = function() return GameWeapons.get_name(getCurrentCharWeapon(PLAYER_PED)); end,
            description = 'Название оружия в руках Вашего персонажа'
        },
        {
            flag = 'gender',
            fn = function() return Utils.isModelMale(getCharModel(PLAYER_PED)) and 'MALE' or 'FEMALE'; end,
            description = 'Пол Вашего персонажа (MALE / FEMALE)'
        },
        {
            flag = 'status',
            fn = function() return (isCharInAnyCar(PLAYER_PED) and '' or 'NOT ') .. 'IN CAR'; end,
            description = 'Статус персонажа (IN CAR / NOT IN CAR)'
        }
    },
};

function TextFlags:replace(str)
    return str:gsub('{%w+}', function(key)
        for _, flagData in ipairs(self.list) do
            if (key == ('{%s}'):format(flagData.flag)) then
                return flagData.fn();
            end
        end
    end);
end