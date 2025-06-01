---@diagnostic disable:lowercase-global
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

require('text-flags');
-- require('profiles');
require('utils');
require('api');
require('ui');


function Message(...)
    return sampAddChatMessage(('AI RolePlay // %s'):format(table.concat({...}, ' ')), -1);
end

addEventHandler('onSendRpc', function(id, bs)
    if (id == 50) then
        local cmd = raknetBitStreamReadString(bs, raknetBitStreamReadInt32(bs));
        local pattern = '^/' .. ffi.string(UI.cmd) .. '(.*)';
        local prompt = cmd:match(pattern);
        if (prompt) then
            local prompt = prompt:gsub('^(%s+)', '')
            if (API:isGenerationInProcess()) then
                return Message('Пожалуи?ста, дождитесь окончания предыдущеи? генерации!');
            end
            if (#prompt > 0) then
                Message('Генерирую отыгровку по запросу "' .. prompt .. '"...');
                API:generate(
                    UI.model,
                    u8(prompt),
                    ffi.string(UI.input),
                    function(generation, response, choice)
                        ResultWindow.generation = generation;
                        imgui.StrCopy(ResultWindow.buffer, choice or 'NULL');
                        UI.generation.status = false;
                        table.insert(UI.history, { prompt = u8(prompt), result = ffi.string(choice)});
                    end,
                    function(errString, err)
                        ResultWindow.generation = API.generation;
                    end
                );
            else
                Message('Ошибка, введите запрос!');
            end
            return false;
        end
    end
end);

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('airp', function()
        UI.window[0] = not UI.window[0];
    end);
    API:loadModelsList();
    wait(-1);
end