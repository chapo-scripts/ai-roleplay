return function(DL, csize)
    if (imgui.BeginChild('page-2', csize, true, imgui.WindowFlags.NoBackground)) then
        local newDL = imgui.GetWindowDrawList();
        imgui.PushTextWrapPos(240);
        
        local p = imgui.GetCursorScreenPos();
        if (UI.Components.Button('##MODEL', imgui.ImVec2(240, 50))) then
            imgui.OpenPopup('models');
        end
        if (imgui.IsItemHovered()) then
            imgui.SetMouseCursor(imgui.MouseCursor.Hand);
        end

        local modelName = API.models[UI.model] and tostring(API.models[UI.model].name) or u8'Не выбрано';
        newDL:AddTextFontPtr(UI.font[30].Bold, 30, p + imgui.ImVec2(10, 10), 0xFFffffff, ti'brain')
        imgui.PushFont(UI.font[16].Bold);
        newDL:AddTextFontPtr(UI.font[16].Bold, 16, p + imgui.ImVec2(10 + 30 + 10, 0 + 25 - imgui.CalcTextSize(modelName, nil, false, 140).y / 2), 0xFFffffff, modelName, nil, 140);
        imgui.PopFont();
        newDL:AddTextFontPtr(UI.font[30].Bold, 30, p + imgui.ImVec2(240 - 10 - 25, 10), 0xFFffffff, ti'caret-down')

        imgui.SetNextWindowPos(p + imgui.ImVec2(0, 50));
        imgui.SetNextWindowSize(imgui.ImVec2(240, 500))
        if (imgui.BeginPopup('models', nil)) then
            imgui.SetMouseCursor(imgui.MouseCursor.Hand);
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
        imgui.TextDisabled(u8'Выберите модель ИИ, а так же введите промпт. В промпте ПОДРОБНО опишите желаемый формат сообщений.\n\n(!) Не забудьте указать что ответ необходимо получать в "построчном" режиме и без лишних комментариев!');
        imgui.NewLine();
        UI.Components.Input('##cmd', u8'Команда для генерации', 0, UI.cmd, nil, nil, 240);
        imgui.NewLine();
        
        imgui.TextDisabled(u8('Версия: %s\nАвтор: chapo ( t.me/moujeek )\nАвтор оригинальной идеи: @kdevworld'):format(thisScript().version));

        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 400 - 10, 10))
        local p = imgui.GetCursorScreenPos();
        local isize = imgui.ImVec2(400, imgui.GetWindowHeight() - 20);
        DL:AddRectFilled(p, p + isize, imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, 1)), 10);
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 0));
        imgui.InputTextMultiline('##prompt', UI.prompt, ffi.sizeof(UI.prompt), isize);
        imgui.PopStyleColor();
    end
    imgui.EndChild();
end