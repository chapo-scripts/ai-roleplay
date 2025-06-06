---@diagnostic disable:lowercase-global
DEV = LUBU_BUNDLED == nil; ---@diagnostic disable:lowercase-global
script_name('AI RolePlay');
script_version('v0.1.1');
script_author('chapo');

GameWeapons = require('game.weapons');

ffi = require('ffi');
imgui = require('mimgui');
ti = require('tabler_icons');
encoding = require('encoding');
encoding.default = 'CP1251';
u8 = encoding.UTF8;

require('config');
require('text-flags');
require('utils');
require('api');
require('ui');


function Message(...)
    return sampAddChatMessage(('AI RolePlay // {ffffff}%s'):format(table.concat({...}, ' ')), 0xFFe53978);
end

function Handler(prompt)
    local prompt = prompt:gsub('^(%s+)', '')
    if (API:isGenerationInProcess()) then
        return Message('Пожалуи?ста, дождитесь окончания предыдущеи? генерации!');
    end
    if (#prompt > 0) then
        local bio = TextFlags:replace(ffi.string(Config.bio));
        Message('Генерирую отыгровку по запросу "' .. u8:decode(prompt) .. '"...');
        ResultWindow.from = {
            source = 'generation',
            prompt = prompt,
            index = -1
        };
        API:generate(
            Config.model,
            bio,
            prompt,
            function()
                imgui.StrCopy(ResultWindow.buffer, API.generation.result or 'NULL');
                if (not API.generation.error) then
                    table.insert(Config.history, { prompt = prompt, result = API.generation.result});
                    Config();
                end
                ResultWindow.window[0] = true;
            end,
            function(errString, err)
                ResultWindow.generation = API.generation;
                ResultWindow.window[0] = true;
            end
        );
    else
        Message('Ошибка, введите запрос!');
    end
end

addEventHandler('onSendRpc', function(id, bs)
    if (id == 50) then
        local cmd = raknetBitStreamReadString(bs, raknetBitStreamReadInt32(bs));
        local pattern = '^/' .. ffi.string(Config.command) .. '(.*)';
        local prompt = cmd:match(pattern);
        if (prompt) then
            Handler(u8(prompt));
            return false;
        end
    end
end);

function main()
    while not isSampAvailable() do wait(0) end
    Message('Введите {e53978}/airp {ffffff}для открытия меню ( {3992e5}t.me/chaposcripts{ffffff} )');
    sampRegisterChatCommand('airp', function()
        UI.window[0] = not UI.window[0];
    end);
    sampRegisterChatCommand('airp.reboot', function()
        Message('Перезагрузка...');
        thisScript():reload();
    end);
    API:loadModelsList();
    wait(-1);
end