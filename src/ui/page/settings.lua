return function(csize)
    if (imgui.BeginChild('page-2', csize, true, imgui.WindowFlags.NoBackground)) then
        local DL = imgui.GetWindowDrawList();
        local p = imgui.GetCursorScreenPos();
        if (UI.Components.Button('##MODEL', imgui.ImVec2(240, 50))) then
            imgui.OpenPopup('models');
        end
        local modelName = API.models[UI.model] and tostring(API.models[UI.model].name) or u8'Не выбрано';
        DL:AddTextFontPtr(UI.font[30].Bold, 30, p + imgui.ImVec2(10, 10), 0xFFffffff, ti'brain')
        imgui.PushFont(UI.font[16].Bold);
        DL:AddTextFontPtr(UI.font[16].Bold, 16, p + imgui.ImVec2(10 + 30 + 10, 0 + 25 - imgui.CalcTextSize(modelName, nil, false, 140).y / 2), 0xFFffffff, modelName, nil, 140);
        imgui.PopFont();
        DL:AddTextFontPtr(UI.font[30].Bold, 30, p + imgui.ImVec2(240 - 10 - 25, 10), 0xFFffffff, ti'caret-down')

        imgui.SetNextWindowPos(p + imgui.ImVec2(0, 50));
        imgui.SetNextWindowSize(imgui.ImVec2(240, 500))
        if (imgui.BeginPopup('models', nil)) then
            imgui.PushFont(UI.font[16].Bold);
            for k, v in pairs(API.models) do
                if (imgui.Selectable(v.name, UI.model == k, 0, imgui.ImVec2(200, 16))) then
                    UI.model = k;
                end
                -- UI.Components.Button(v.name, imgui.ImVec2(200, 25))
            end
            imgui.EndPopup();
            imgui.PopFont();
        end
        imgui.NewLine();
        UI.Components.Input('##cmd', u8'Команда для генерации', 0, UI.cmd, nil, nil, 240);
        imgui.NewLine();
        imgui.PushTextWrapPos(240);
        imgui.TextDisabled(u8('Версия: %s\nАвтор: chapo ( t.me/moujeek )\nАвтор оригинальной идеи: @internalities'):format(thisScript().version));

        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 400 - 10, 10))
        imgui.InputTextMultiline('##prompt', UI.prompt, ffi.sizeof(UI.prompt), imgui.ImVec2(400, imgui.GetWindowHeight() - 20));
    end
    imgui.EndChild();
end