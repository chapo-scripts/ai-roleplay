TextFlags = {
    list = {
        {
            flag = 'id',
            fn = function() return tostring(Utils.myid()) end,
            description = 'ID ������ ���������'
        },
        {
            flag = 'name',
            fn = function() return sampGetPlayerNickname(Utils.myid()) end,
            description = '��� ������ ���������'
        },
        {
            flag = 'lvl',
            fn = function() return sampGetPlayerScore(Utils.myid()) end,
            description = '������� ������ ���������'
        },
        {
            flag = 'weapon',
            fn = function() return GameWeapons.get_name(getCurrentCharWeapon(PLAYER_PED)); end,
            description = '�������� ������ � ����� ������ ���������'
        },
        {
            flag = 'gender',
            fn = function() return Utils.isModelMale(getCharModel(PLAYER_PED)) and 'MALE' or 'FEMALE'; end,
            description = '��� ������ ��������� (MALE / FEMALE)'
        },
        {
            flag = 'status',
            fn = function() return (isCharInAnyCar(PLAYER_PED) and '' or 'NOT ') .. 'IN CAR'; end,
            description = '������ ��������� (IN CAR / NOT IN CAR)'
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