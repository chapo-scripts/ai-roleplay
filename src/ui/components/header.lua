return function(size)
    if (imgui.BeginChild('header', imgui.ImVec2(size.x - 20, 60), false, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)) then
        imgui.PushFont(UI.font[50].Bold);
        imgui.SetCursorPos(imgui.ImVec2(5, 10))
        imgui.Text(ti'brain');
        imgui.SetCursorPos(imgui.ImVec2(75, 5))
        imgui.Text('AI RolePlay');
        imgui.PopFont();
        imgui.PushFont(UI.font[25].Bold);
        imgui.SetCursorPos(imgui.ImVec2(50, 10))
        imgui.Text(ti'bubble-text');
        imgui.PopFont();
    end
    imgui.EndChild();
end