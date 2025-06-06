

UI = {
    window = imgui.new.bool(true),
    Components = {
        Button = require('ui.components.button'),
        SelectableButton = require('ui.components.selectable-button'),
        Input = require('ui.components.input'),
        Navigation = require('ui.components.nav'),
        Header = require('ui.components.header'),
        Spinner = require('ui.components.spinner'),
        CenterText = require('ui.components.center-text'),
        Hint = require('ui.components.hint')
    },
    Page = {
        home = require('ui.page.home'),
        settings = require('ui.page.settings'),
    },
    font = {},
    input = imgui.new.char[1024](u8'*я в машине, меня остановил коп* открыл окно, достал паспорт из бордачка и протянул копу в окно'),
    tabs = {
        { name = 'home', icon = ti'home' },
        { name = 'settings', icon = ti'settings' }
    },
    tab = imgui.new.int(1),
    tabAnimation = {
        start = os.clock(),
        x = 0,
        scroll = 0,
        alpha = 0
    },
    generation = {
        status = false,
        error = nil,
        result = {}
    },
};

ResultWindow = {
    window = imgui.new.bool(false),
    buffer = imgui.new.char[2048](''),
    generation = {},
    delay = imgui.new.int(1000),
    from = {
        prompt = 'none',
        source = 'generation',
        index = 1
    }
};

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil;
    require('ui.style').init()
    require('ui.fonts').init()
end);

imgui.OnFrame(
    function() return UI.window[0] end,
    function(thisWindow)
        if (DEV) then
            imgui.GetBackgroundDrawList():AddRectFilled(imgui.ImVec2(0, 0), imgui.GetIO().DisplaySize, imgui.GetColorU32Vec4(imgui.ImVec4(0, 1, 0.03, 1)));
        end
        local res = imgui.ImVec2(getScreenResolution());
        local size = imgui.ImVec2(700, 450);
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver);
        if (imgui.Begin('Main Window', UI.window, imgui.WindowFlags.NoDecoration)) then
            local size = imgui.GetWindowSize();
            local DL = imgui.GetWindowDrawList();

            UI.Components.Header(size);
            
            local csize = imgui.ImVec2(size.x - 30, size.y - 60 - 15 - 15)
            imgui.SetCursorPos(imgui.ImVec2(-UI.tabAnimation.scroll, 60 + 15));
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0, 0, 0, 0));
            UI.Page.home(DL, csize, function()
                Handler(ffi.string(UI.input));
            end);
            imgui.SameLine(nil, 15);
            UI.Page.settings(DL, csize);
            imgui.PopStyleColor();
            UI.Components.Navigation(imgui.GetForegroundDrawList(), size, csize);

            imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 37, 0));
            local p = imgui.GetCursorScreenPos();
            DL:AddRectFilled(p, p + imgui.ImVec2(30, 20), imgui.GetColorU32Vec4(imgui.ImVec4(0.55, 0.1, 0.1, 1)), 5, 4 + 8);
            imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 5);
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.55, 0.1, 0.1, 1));
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.74, 0.19, 0.19, 1));
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.74, 0.19, 0.19, 1));
            if (UI.Components.Button('X', imgui.ImVec2(30, 20))) then
                UI.window[0] = false;
            end
            imgui.PopStyleColor(3);
            imgui.PopStyleVar();
        end
        imgui.End();
    end
);

local function send(text, delay)
    lua_thread.create(function()
        local text = u8:decode(text);
        for line in text:gmatch('[^\n]+') do
            if (#line:gsub('%s+', '') > 0) then
                sampSendChat(line);
                wait(delay);
            end
        end
        Message('Отправка завершена!');
    end)
end

imgui.OnFrame(
    function() return ResultWindow.window[0] end,
    function(thisWindow)
        local source = ResultWindow.from.source;
        local isError = API.generation.error ~= nil;
        local res = imgui.ImVec2(getScreenResolution());
        local size = imgui.ImVec2(500, isError and 100 or 600);
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver);
        imgui.PushStyleVarVec2(imgui.StyleVar.WindowMinSize, imgui.ImVec2(300, 300));
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 5);
        if (imgui.Begin('AI-RolePlay-Generation-Result', ResultWindow.window, imgui.WindowFlags.NoTitleBar + (isError and imgui.WindowFlags.AlwaysAutoResize or 0))) then
            local size = imgui.GetWindowSize();
            imgui.PushFont(UI.font[20].Bold);
            imgui.TextDisabled((source == 'generation' or source == 'history') and u8'Результат генерации' or u8'Сохраненная генерация');
            imgui.PopFont();

            imgui.PushFont(UI.font[16].Bold);
            imgui.TextDisabled(u8'Запрос: ');
            imgui.SameLine(nil, 0);
            imgui.TextWrapped(tostring(ResultWindow.from.prompt)); --tostring(ResultWindow.fromFavorites and Config.favorites[ResultWindow.fromFavorites].prompt or API.generation.lastPrompt)
            if (isError) then
                imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8'Произошла ошибка: ');
                imgui.TextWrapped(tostring(API.generation.error));
                imgui.TextDisabled(u8'Попробуйте выбрать другую модель в настройках!');
                if (UI.Components.Button(u8'X Закрыть', imgui.ImVec2(size.x - 20, 25))) then
                    ResultWindow.window[0] = false;
                end
            else
                imgui.InputTextMultiline('##gen-res', ResultWindow.buffer, ffi.sizeof(ResultWindow.buffer), imgui.ImVec2(size.x - 20, size.y - imgui.GetCursorPosY() - 5 - 24 * 4 - (source == 'favorites' and 25 or 0)));
                imgui.SetNextItemWidth(size.x - 20);
                imgui.SliderInt('##delay', ResultWindow.delay, 0, 3000, u8'Задержка: %d мс.');
                if (UI.Components.Button(ti'send-2' .. u8' Отправить в чат', imgui.ImVec2(size.x - 20, 25))) then
                    send(ffi.string(ResultWindow.buffer), ResultWindow.delay[0])
                    ResultWindow.window[0] = false;
                    Config();
                end
                if (UI.Components.Button(u8'X Закрыть', imgui.ImVec2(size.x - 20, 25))) then
                    ResultWindow.window[0] = false;
                end
                if (ResultWindow.from.source == 'favorites') then
                    if (UI.Components.Button(ti'check' .. u8' Сохранить', imgui.ImVec2(size.x - 20, 25))) then
                        Config.favorites[ResultWindow.from.index].result = ffi.string(ResultWindow.buffer);
                        ResultWindow.window[0] = false;
                        Config();
                    end
                end
            end
            imgui.PopFont();
        end
        imgui.End();
        imgui.PopStyleVar(2);
    end
);
