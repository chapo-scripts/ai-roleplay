

UI = {
    window = imgui.new.bool(true),
    Components = {
        Button = require('ui.components.button'),
        SelectableButton = require('ui.components.selectable-button'),
        Input = require('ui.components.input'),
        Navigation = require('ui.components.nav'),
        Header = require('ui.components.header'),
        Spinner = require('ui.components.spinner')
    },
    Page = {
        home = require('ui.page.home'),
        settings = require('ui.page.settings'),
    },
    font = {},
    prompt = imgui.new.char[2048](u8[[
Ты - помощник который должен описать RolePlay отыгровку действия моего персонажа.
Я отправляю тебе краткое описание отыгровки, а ты должен в ответ прислать список сообщений,
которые я должен отправить в чат что бы отыграть ситуацию. Используй команды /me и /do.

Отвечай без лишних комментариев, ТОЛЬКО ОТЫГРОВКИ. Каждое предложение должно быть написано с новой строки
    ]]),
    input = imgui.new.char[1024](u8'Достал паспорт из кармана'),
    tabs = {
        { name = 'home', icon = ti'home' },
        { name = 'settings', icon = ti'settings' }
    },
    tab = imgui.new.int(1),
    history = {
        { prompt = 'Hello', result = 'World' }
    },
    favorites = {},
    tabAnimation = {
        start = os.clock(),
        x = 0,
        scroll = 0,
        alpha = 0
    },
    cmd = imgui.new.char[32]('/airp'),
    generation = {
        status = false,
        error = nil,
        result = {}
    },
    model = 'gpt-4o'
};

ResultWindow = {
    window = imgui.new.bool(true),
    buffer = imgui.new.char[2048](''),
    generation = nil,
    delay = imgui.new.int(1000)
};

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil;
    require('ui.style').init()
    require('ui.fonts').init()
end);

imgui.OnFrame(
    function() return UI.window[0] end,
    function(thisWindow)
        local res = imgui.ImVec2(getScreenResolution());
        local size = imgui.ImVec2(700, 450);
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver);
        if (imgui.Begin('Main Window', UI.window, imgui.WindowFlags.NoDecoration)) then
            local size = imgui.GetWindowSize();
            UI.Components.Header(size);
            
            local csize = imgui.ImVec2(size.x - 30, size.y - 60 - 15 - 15)
            imgui.SetCursorPos(imgui.ImVec2(-UI.tabAnimation.scroll, 60 + 15));
            UI.Page.home(csize, function()
                API:generate(
                    UI.model,
                    ffi.string(UI.prompt),
                    ffi.string(UI.input),
                    function()
                        imgui.StrCopy(ResultWindow.buffer, API.generation.result or 'NULL');
                        UI.generation.status = false;
                        table.insert(UI.history, { prompt = ffi.string(UI.input), result = API.generation.result});
                        ResultWindow.window[0] = true;
                    end,
                    function(errString, err)
                        ResultWindow.generation = API.generation;
                        ResultWindow.window[0] = true;
                    end
                );
            end);
            imgui.SameLine(nil, 15);
            UI.Page.settings(csize);
            UI.Components.Navigation(size, csize);
        end
        imgui.End();
    end
);

local function send(text, delay)
    lua_thread.create(function()
        local text = u8:decode(text);
        for line in text:gmatch('[^\n]+') do
            sampSendChat(line);
            wait(delay);
        end
    end)
end

imgui.OnFrame(
    function() return ResultWindow.window[0] end,
    function(thisWindow)
        local res = imgui.ImVec2(getScreenResolution());
        local size = imgui.ImVec2(500, 600);
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver);
        local isError = API.generation.error ~= nil;
        if (imgui.Begin('AI-RolePlay-Generation-Result', ResultWindow.window, imgui.WindowFlags.NoDecoration + (isError and imgui.WindowFlags.AlwaysAutoResize or 0))) then
            imgui.PushFont(UI.font[20].Bold);
            imgui.TextDisabled(ResultWindow.fromFavorites and u8'Сохраненная генерация: ' .. (UI.favorites[ResultWindow.fromFavorites].prompt) or u8'Результат генерации');
            imgui.PopFont();
            imgui.PushFont(UI.font[16].Bold);
            
            if (isError) then
                imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8'Произошла ошибка: ');
                imgui.TextWrapped(tostring(API.generation.error));
                if (UI.Components.Button(u8'X Закрыть', imgui.ImVec2(size.x - 20, 25))) then
                    ResultWindow.window[0] = false;
                end
            else
                imgui.InputTextMultiline('##gen-res', ResultWindow.buffer, ffi.sizeof(ResultWindow.buffer), imgui.ImVec2(size.x - 20, size.y - 50 - 25 - 5 - 25 - 25 - (ResultWindow.fromFavorites and 25 or 0)));
                imgui.SetNextItemWidth(size.x - 20);
                imgui.SliderInt('##delay', ResultWindow.delay, 0, 3000, u8'Задержка: %d мс.');
                if (UI.Components.Button(ti'send-2' .. u8' Отправить в чат', imgui.ImVec2(size.x - 20, 25))) then
                    send(ffi.string(ResultWindow.buffer), ResultWindow.delay[0])
                    ResultWindow.window[0] = false;
                end
                if (UI.Components.Button(u8'X Закрыть', imgui.ImVec2(size.x - 20, 25))) then
                    ResultWindow.window[0] = false;
                end
                if (ResultWindow.fromFavorites) then
                    if (UI.Components.Button(ti'check' .. u8' Сохранить', imgui.ImVec2(size.x - 20, 25))) then
                        UI.favorites[ResultWindow.fromFavorites].result = ffi.string(ResultWindow.buffer);
                        ResultWindow.window[0] = false;
                    end
                end
            end
            imgui.PopFont();
        end
        imgui.End();
    end
);
