return function(text, c)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2);
    imgui.TextColored(c or imgui.ImVec4(1, 1, 1, 1), text);
end