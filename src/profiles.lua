---@class Profile
---@field name string
---@field model string
---@field prompt string

PROFILES_DIR = getGameDirectory() .. '\\moonloader\\AI-RolePlay\\';
Profiles = {
    list = {}
};

function Profiles:init()
    if (not doesDirectoryExist(PROFILES_DIR)) then
        createDirectory(PROFILES_DIR);
    end
    self:updateList();
end

function Profiles:updateList()
    Profiles.list = {};
    for _, filename in ipairs(Utils.getFilesInPath(PROFILES_DIR, '*.json')) do
        local file = io.open(filename, 'r');
        if (file) then
            local content = file:read('*all');
            file:close();
            local decoded = decodeJson(content);
            if (not decoded or not decoded.name or not decoded.model or not decoded.prompt) then
                return Message(('Ошибка загрузки профиля "%s": не удалось прочитать JSON!'):format(filename));
            end
            table.insert(Profiles.list, decoded);
        else
            Message(('Ошибка загрузки профиля "%s": не удалось открыть файл!'):format(filename));
        end
    end
end

function Profiles:save(name, model, prompt)
    local profile = {
        name = name,
        model = model,
        prompt = prompt
    };
    local filename = PROFILES_DIR .. name .. '.json';
    local file = io.open(filename, 'w');
    if (file) then
        file:write(encodeJson(profile));
        file:close();
        self:updateList();
    else
        Message(('Ошибка сохранения профиля "%s": не удалось открыть файл!'):format(filename));
    end
end