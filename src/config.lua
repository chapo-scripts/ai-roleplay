local inicfg = require('inicfg');
local directIni = 'AI-RolePlay.ini';
local ini = inicfg.load({
    main = {
        command = 'airpg',
        model = 'gemini-2.0-flash',
        bio = '',
        sendDelay = 1000
    },
}, directIni);
inicfg.save(ini, directIni);

Config = {};

function Config:load()
    imgui.StrCopy(UI.cmd, ini.main.command);
    UI.model = ini.main.model;
    imgui.StrCopy(UI.prompt, ini.main.bio);
    ResultWindow.delay[0] = ini.main.sendDelay;
end

function Config:save()
    ini.main.command = ffi.string(UI.cmd);
    ini.main.model = UI.model;
    ini.main.bio = ffi.string(UI.prompt);
    ini.main.sendDelay = ResultWindow.delay[0];
    inicfg.save(ini, directIni);
end