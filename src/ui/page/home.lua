local function isHistoryItemLiked(item)
    for k, v in ipairs(UI.favorites) do
        if (v.prompt == item.prompt and v.result == item.result) then
            return k;
        end
    end
end

return function(csize, inputCallback)
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
        if (imgui.BeginChild('home-favorites', tsize, true)) then
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
            end
        end
        imgui.EndChild();
        imgui.SameLine(tsize.x + 15 + 15);
        if (imgui.BeginChild('home-history', tsize, true)) then
            for index, data in ipairs(UI.history) do
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
                
                if (imgui.Selectable(data.prompt .. '##history-' .. index, false)) then
                    if (API:isGenerationInProcess()) then
                        Message('Ошибка, дождитесь окончания генерации!');
                    else
                        ResultWindow.window[0] = true;
                        imgui.StrCopy(ResultWindow.buffer, data.result);
                        ResultWindow.fromFavorites = nil;
                    end
                end
            end
        end
        imgui.EndChild();
        imgui.PopFont();
    end
    imgui.EndChild();
end