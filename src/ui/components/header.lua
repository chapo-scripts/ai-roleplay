local paskhalko = {
    count = 0,
    last = os.time();
};

return function(size)
    if (imgui.BeginChild('header', imgui.ImVec2(size.x - 20, 60), false, imgui.WindowFlags.NoMouseInputs + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)) then
        imgui.PushFont(UI.font[50].Bold);
        imgui.SetCursorPos(imgui.ImVec2(5, 10));
        local c = imgui.GetCursorScreenPos();
        imgui.Text(ti'brain');
        if (imgui.IsMouseClicked(0) and imgui.IsMouseHoveringRect(c, c + imgui.ImVec2(50, 50))) then
            paskhalko.count = paskhalko.count + 1;
            paskhalko.last = os.time();
            if (paskhalko.count >= 5) then
                paskhalko.count = 0;
                os.execute('explorer.exe "https://youtu.be/P37mn84nabg?si=DDpVy0G6D0YUyKSi"');
            end
        end
        if (os.time() - paskhalko.last >= 1.5) then
            paskhalko.count = 0;
        end
        
        imgui.SetCursorPos(imgui.ImVec2(75, 5));
        imgui.Text('AI RolePlay');
        imgui.PopFont();
        imgui.PushFont(UI.font[25].Bold);
        imgui.SetCursorPos(imgui.ImVec2(50, 10));
        imgui.Text(ti'bubble-text');
        imgui.PopFont();
    end
    imgui.EndChild();
end