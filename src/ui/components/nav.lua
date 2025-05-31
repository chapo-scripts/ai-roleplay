return function(size, csize, navSize)
    local navSize = imgui.ImVec2(100, 40);
    imgui.SetCursorPos(imgui.ImVec2(size.x / 2 - navSize.x / 2, size.y - navSize.y - 15));
    local p = imgui.GetCursorScreenPos();
    local DL = imgui.GetForegroundDrawList();
    local color = imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.ChildBg]);
    DL:AddRectFilled(p, p + navSize, color, 10)
    
    local buttonSize = imgui.ImVec2(50, navSize.y);
    DL:AddRectFilled(p + imgui.ImVec2(UI.tabAnimation.x, 0), p + imgui.ImVec2(UI.tabAnimation.x, 0) + buttonSize, 0xFFffffff, 10)
    
    UI.tabAnimation.x = Utils.bringFloatTo(UI.tabAnimation.x, (UI.tab[0] == 1 and 0 or buttonSize.x), UI.tabAnimation.start, 0.5)
    UI.tabAnimation.alpha = Utils.bringFloatTo(0, 1, UI.tabAnimation.start, 0.5)
    UI.tabAnimation.scroll = Utils.bringFloatTo(UI.tab[0] == 1 and csize.x or -15, UI.tab[0] == 1 and -15 or csize.x, UI.tabAnimation.start, 0.2);
    
    for index, page in ipairs(UI.tabs) do
        local textPos = imgui.ImVec2(p.x + (50 / 2 - 25 / 2) + (index == 2 and 25 + 25 or 0), p.y + (navSize.y / 2 - 25 / 2))
        local c = UI.tab[0] == index and 1 - UI.tabAnimation.alpha or UI.tabAnimation.alpha;
        DL:AddTextFontPtr(UI.font[25].Bold, 25, textPos, imgui.GetColorU32Vec4(imgui.ImVec4(c, c, c, 1)), page.icon);
        if (UI.tab[0] ~= index and imgui.IsMouseClicked(0) and imgui.IsMouseHoveringRect(textPos, textPos + imgui.ImVec2(15 + 25 + 15, navSize.y))) then
            UI.tab[0] = index;
            UI.tabAnimation.start = os.clock()
        end
    end
    DL:AddRect(p - imgui.ImVec2(5, 5), p + imgui.ImVec2(5, 5) + navSize, imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.WindowBg]), 10, nil, 10)

end