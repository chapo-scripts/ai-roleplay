return function (label, value, current, size)
    local DL = imgui.GetWindowDrawList()
    local text = label:gsub('##.+', '') or ''
    local p = imgui.GetCursorScreenPos()

    local ts = imgui.CalcTextSize(text)
    local size = size or (ts + imgui.ImVec2(10, 10))

    local clicked = imgui.InvisibleButton(label, size)
    local hovered = imgui.IsItemHovered()

    if clicked and value[0] ~= current then
        value[0] = current
    end

    DL:AddRectFilled(p, p + size, imgui.GetColorU32Vec4((value[0] == current) and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or (hovered and imgui.GetStyle().Colors[imgui.Col.ButtonHovered] or imgui.GetStyle().Colors[imgui.Col.Button])), imgui.GetStyle().FrameRounding)
    DL:AddText(p + imgui.ImVec2(size.x/2 - ts.x/2, size.y/2 - ts.y/2), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Text]), text)

    return clicked
end