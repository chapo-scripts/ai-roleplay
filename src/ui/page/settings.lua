local bioAnimation = {
    hovered = false,
    start = 0,
    alpha = 0
};

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

        local modelName = API.models[Config.model] and tostring(API.models[Config.model].name) or u8'Не выбрано';
        newDL:AddTextFontPtr(UI.font[30].Bold, 30, p + imgui.ImVec2(10, 10), 0xFFffffff, ti'brain')
        imgui.PushFont(UI.font[16].Bold);
        newDL:AddTextFontPtr(UI.font[16].Bold, 16, p + imgui.ImVec2(10 + 30 + 10, 0 + 25 - imgui.CalcTextSize(modelName, nil, false, 140).y / 2), 0xFFffffff, modelName, nil, 140);
        imgui.PopFont();
        newDL:AddTextFontPtr(UI.font[30].Bold, 30, p + imgui.ImVec2(240 - 10 - 25, 10), 0xFFffffff, ti'caret-down')

        imgui.SetNextWindowPos(p + imgui.ImVec2(0, 50));
        imgui.SetNextWindowSize(imgui.ImVec2(240, 500))
        if (imgui.BeginPopup('models', 0)) then
            imgui.SetMouseCursor(imgui.MouseCursor.Hand);
            imgui.PushFont(UI.font[16].Bold);
            for k, v in pairs(API.models) do
                if (imgui.Selectable(v.name, Config.model == k, 0, imgui.ImVec2(200, 16))) then
                    Config.model = k;
                    Config();
                end
            end
            imgui.EndPopup();
            imgui.PopFont();
        end
        imgui.NewLine();
        imgui.TextDisabled(u8'Выберите модель ИИ, а так же введите промпт. В промпте ПОДРОБНО опишите желаемый формат сообщений.\n\n(!) Не забудьте указать что ответ необходимо получать в "построчном" режиме и без лишних комментариев!');
        imgui.NewLine();
        if (UI.Components.Input('##cmd', u8'Команда для генерации (без "/")', 0, Config.command, nil, nil, 240)) then
            Config();
        end
        imgui.NewLine();
        
        imgui.TextDisabled(u8('Версия: %s\nАвтор: chapo ( t.me/moujeek )\nАвтор оригинальной идеи: @kdevworld'):format(thisScript().version));

        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 400 - 10, 10))
        local p = imgui.GetCursorScreenPos();
        local isize = imgui.ImVec2(400, imgui.GetWindowHeight() - 20);
        DL:AddRectFilled(p, p + isize, imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, 1)), 10);
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, bioAnimation.alpha + 0.2));

        local c, ca = imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, 1)), imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, 0))
        if (imgui.BeginChild('prompt', isize - imgui.ImVec2(0, 35), true, imgui.WindowFlags.NoScrollbar)) then
            imgui.TextWrapped(ffi.string(Config.bio));
            imgui.GetWindowDrawList():AddRectFilledMultiColor(
                p + imgui.ImVec2(0, isize.y - 35 - 70),
                p + imgui.ImVec2(isize.x, isize.y - 35),
                ca,
                ca,
                c,
                c
            );
        end
        imgui.EndChild();
        
        DL:AddRectFilled(p + imgui.ImVec2(0, isize.y - 30), p + imgui.ImVec2(isize.x, isize.y), imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, 1)), 10, 4 + 8)
        local isHovered = imgui.IsItemHovered() or imgui.IsItemActive();
        if (isHovered ~= bioAnimation.hovered) then
            bioAnimation.hovered = isHovered;
            bioAnimation.start = os.clock();
        end
        bioAnimation.alpha = Utils.bringFloatTo(bioAnimation.hovered and 1 or 0, bioAnimation.hovered and 0 or 1, bioAnimation.start, 0.2);
        imgui.PushFont(UI.font[25].Bold);
        local textSize = imgui.CalcTextSize(u8'Нажмите что бы изменить промпт');
        DL:AddTextFontPtr(
            UI.font[25].Bold,
            25,
            p + imgui.ImVec2(isize.x / 2 - textSize.x / 2, 50),
            imgui.GetColorU32Vec4(imgui.ImVec4(1, 1, 1, 1 - bioAnimation.alpha)),
            u8'Нажмите что бы изменить промпт'
        );
        imgui.PopFont();
        imgui.PushFont(UI.font[16].Bold);
        DL:AddTextFontPtr(
            UI.font[16].Bold,
            16,
            p + imgui.ImVec2(15, 50 + 25 + 15),
            imgui.GetColorU32Vec4(imgui.ImVec4(1, 1, 1, 1 - bioAnimation.alpha)),
            u8'Промпт (от англ. prompt) - это запрос к нейросети с целью получить желаемое изображение или текст. Чем четче и правильнее прописан промпт, тем более релевантным будет результат.\n\nЗдесь вы можете описать роль своего персонажа что бы повысить качество генерации отыгровок!',
            nil,
            isize.x - 30
        );
        imgui.PopFont();
        if (isHovered) then
            imgui.SetMouseCursor(imgui.MouseCursor.Hand);
            if (imgui.IsMouseClicked(0)) then
                imgui.OpenPopup('edit-prompt');
            end
        end
        -- imgui.GetWindowDrawList():AddRectFilled(p, p + isize, imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, bioAnimation.alpha)), 10);
        imgui.PushStyleVarVec2(imgui.StyleVar.WindowMinSize, imgui.ImVec2(500, 200));
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 5);
        imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.WindowBg]);
        if (imgui.BeginPopupModal('edit-prompt', nil, imgui.WindowFlags.NoTitleBar)) then
            local size = imgui.GetWindowSize();
            imgui.PushFont(UI.font[20].Bold);
            imgui.TextDisabled(u8'Редактирование промпта');
            imgui.PopFont();
            UI.Components.Button(u8'Флаги', imgui.ImVec2(size.x - 20, 30));
            local flagsList = {};
            for k, v in ipairs(TextFlags.list) do
                table.insert(flagsList, u8('{%s} - %s. Текущее значение: %s'):format(v.flag, u8(v.description), tostring(v.fn())));
            end
            UI.Components.Hint('flags-hint', u8([[
Для создания более подробного промпта Вы можете использовать следующие "флаги":
Флаг | Описание | Значение
%s
            ]]):format(table.concat(flagsList, '\n')), nil, true);
            -- if (imgui.CollapsingHeader(u8'Флаги')) then
            --     imgui.PushFont(UI.font[18].Bold);
            --     imgui.TextDisabled(u8'Флаги');
            --     imgui.PopFont();
            --     imgui.PushFont(UI.font[16].Bold);
            --     imgui.TextDisabled(u8'Для создания более подробного промпта Вы можете использовать следующие "флаги":');
            --     imgui.Columns(3);
            --     imgui.Text(u8'Флаг');
            --     imgui.SetColumnWidth(-1, 100);
            --     imgui.NextColumn();
            --     imgui.Text(u8'Значение');
            --     imgui.SetColumnWidth(-1, 150);
            --     imgui.NextColumn();
            --     imgui.Text(u8'Описание');
            --     imgui.Columns(1);
            --     imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 0.5));
            --     for k, v in ipairs(TextFlags.list) do
            --         imgui.Columns(3);
            --         imgui.Text(('{%s}'):format(v.flag));
            --         imgui.SetColumnWidth(-1, 100);
            --         imgui.NextColumn();
            --         imgui.Text(tostring(v.fn()));
            --         imgui.SetColumnWidth(-1, 150);
            --         imgui.NextColumn();
            --         imgui.Text(u8(v.description));
            --         imgui.Columns(1);
            --     end
            --     imgui.PopStyleColor();
            --     imgui.PopFont();
            -- end
            imgui.InputTextMultiline('##prompt', Config.bio, ffi.sizeof(Config.bio), imgui.ImVec2(size.x - 20, size.y - imgui.GetCursorPosY() - 30 - 15));
            
            if (UI.Components.Button(ti'check' .. u8' Сохранить##save-bio', imgui.ImVec2(size.x - 20, 30))) then
                Config();
                imgui.CloseCurrentPopup();
            end
            imgui.EndPopup();
        end
        imgui.PopStyleColor();
        imgui.PopStyleVar();
    end
    imgui.EndChild();
end