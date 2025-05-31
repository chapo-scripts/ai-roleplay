local function isHistoryItemLiked(item)
    for k, v in ipairs(UI.favorites) do
        if (v.prompt == item.prompt and v.result == item.result) then
            return k;
        end
    end
end

return function(DL, csize, inputCallback)
    if (imgui.BeginChild('page-1', csize, true, imgui.WindowFlags.NoBackground)) then
        imgui.PushFont(UI.font[16].Bold);
        imgui.TextDisabled(u8'Генерация отыгровки');
        if (API:isGenerationInProcess()) then
            UI.Components.Spinner('Generation...', 8, 3, 0xFFffffff);
            imgui.SetCursorPos(imgui.ImVec2(40, imgui.GetCursorPosY() - 24));
            imgui.TextDisabled(u8'Генерация отыгровки по запросу "');
            imgui.SameLine(nil, 0);
            imgui.Text(tostring(API.generation.lastPrompt));
            imgui.SameLine(nil, 0);
            imgui.TextDisabled('"');
        else
            local inputChanged = UI.Components.Input('', u8'Введите запрос, например: достал и показал паспорт человеку напротив', imgui.InputTextFlags.EnterReturnsTrue, UI.input, nil, nil, csize.x - 30 - 15 - 20);
            imgui.SameLine(nil, 15);
            local buttonPressed = UI.Components.Button(ti'send-2' .. '##ghen', imgui.ImVec2(30, 28));
            if (inputChanged or buttonPressed) then
                UI.generation.status, UI.generation.result = true, {};
                inputCallback();
            end
        end
        
        imgui.NewLine();
        
        local tsize = imgui.ImVec2((csize.x - 15 - 15 - 15) / 2, csize.y - imgui.GetCursorPosY() - 30);
        
        
        imgui.TextDisabled(u8'Сохраненные отыгровки');
        imgui.SameLine(tsize.x + 15 + 15);
        imgui.TextDisabled(u8'История отыгровок')
        local p = imgui.GetCursorScreenPos();
        DL:AddRectFilled(p, p + tsize, imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, 1)), 10);
    
        if (imgui.BeginChild('home-favorites', tsize, true)) then
            if (#UI.favorites == 0) then
                UI.Components.CenterText(u8'Тут пока пусто :(', imgui.ImVec4(1, 1, 1, 0.5));
            end
            for index, data in ipairs(UI.favorites) do
                local likeIndex = isHistoryItemLiked(data);
                imgui.TextColored(likeIndex and imgui.ImVec4(1, 0, 0, 1) or imgui.ImVec4(1, 1, 1, 1), ti'heart');
                if (imgui.IsItemClicked()) then
                    if (likeIndex == nil) then
                        table.insert(UI.favorites, data);
                    else
                        table.remove(UI.favorites, likeIndex);
                    end
                end
                imgui.SameLine(nil, 10);
                if (imgui.Selectable(data.prompt .. '##favorites-' .. index, false)) then
                    if (API:isGenerationInProcess()) then
                        Message('Ошибка, дождитесь окончания генерации!');
                    else
                        ResultWindow.window[0] = true;
                        imgui.StrCopy(ResultWindow.buffer, data.result);
                        ResultWindow.fromFavorites = index;
                    end
                end
                if (imgui.IsItemHovered()) then
                    imgui.SetMouseCursor(imgui.MouseCursor.Hand);
                end
            end
        end
        imgui.EndChild();
        imgui.SameLine(tsize.x + 15 + 15);
        local p = imgui.GetCursorScreenPos();
        DL:AddRectFilled(p, p + tsize, imgui.GetColorU32Vec4(imgui.ImVec4(0.04, 0.04, 0.04, 1)), 10);
        if (imgui.BeginChild('home-history', tsize, true)) then
            if (#UI.history == 0) then
                UI.Components.CenterText(u8'Тут пока пусто', imgui.ImVec4(1, 1, 1, 0.5));
                UI.Components.CenterText(u8'Сделайте запрос что бы исправить это!', imgui.ImVec4(1, 1, 1, 0.5));
            end
            for index, data in ipairs(UI.history) do
                local likeIndex = isHistoryItemLiked(data);
                imgui.TextColored(likeIndex and imgui.ImVec4(1, 0, 0, 1) or imgui.ImVec4(1, 1, 1, 1), ti'heart');
                local likeHovered = imgui.IsItemHovered();
                if (imgui.IsItemClicked()) then
                    if (likeIndex == nil) then
                        table.insert(UI.favorites, data);
                    else
                        table.remove(UI.favorites, likeIndex);
                    end
                end
                imgui.SameLine(nil, 10);
                
                if (imgui.Selectable(data.prompt .. '##history-' .. index, false, nil, imgui.ImVec2(tsize.x - 16 - 16 - 10 - 20, 16))) then
                    if (API:isGenerationInProcess()) then
                        Message('Ошибка, дождитесь окончания генерации!');
                    else
                        ResultWindow.window[0] = true;
                        imgui.StrCopy(ResultWindow.buffer, data.result);
                        ResultWindow.fromFavorites = nil;
                    end
                end
                local itemHovered = imgui.IsItemHovered();
                imgui.SameLine(nil, 10);
                if (imgui.Text('x') or imgui.IsItemClicked()) then
                    table.remove(UI.history, index);
                end
                local xHovered = imgui.IsItemHovered();
                if (likeHovered or itemHovered or xHovered) then
                    imgui.SetMouseCursor(imgui.MouseCursor.Hand);
                end
            end
        end
        imgui.EndChild();
        imgui.PopFont();
    end
    imgui.EndChild();
end