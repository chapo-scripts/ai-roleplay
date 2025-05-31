return {
    init = function()
        local style = imgui.GetStyle();
        style.WindowRounding = 10;
        style.WindowPadding = imgui.ImVec2(10, 10);
        style.ChildRounding = 10;
        style.WindowBorderSize = 0;
        style.FrameRounding = 10;
        style.PopupBorderSize = 0;
        style.PopupRounding = 10;

        local colors = style.Colors;
        colors[imgui.Col.WindowBg] = imgui.ImVec4(0.07, 0.07, 0.07, 1);
        colors[imgui.Col.ChildBg] = imgui.ImVec4(0.04, 0.04, 0.04, 1);
        colors[imgui.Col.PopupBg] = colors[imgui.Col.ChildBg];
        colors[imgui.Col.Button] = colors[imgui.Col.ChildBg];
        colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.04, 0.04, 0.04, 0.65);
        colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.04, 0.04, 0.04, 0.8);
        colors[imgui.Col.FrameBg] = colors[imgui.Col.Button];
        colors[imgui.Col.FrameBgHovered] = colors[imgui.Col.ButtonHovered];
        colors[imgui.Col.FrameBgActive] = colors[imgui.Col.ButtonActive];
        colors[imgui.Col.Border] = imgui.ImVec4(0, 0, 0, 0);
    end
}