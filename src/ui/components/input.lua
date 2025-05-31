local ffi = require('ffi');
local imgui = require('mimgui');

function bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time; if timer >= 0.00 and timer <= duration then local count = timer / (duration / 100) return from + (count * (to - from) / 100), true end; return (timer > duration) and to or from, false
end

function bringVec4To(from, to, start_time, duration)
    local timer = os.clock() - start_time if timer >= 0.00 and timer <= duration then local count = timer / (duration / 100) return imgui.ImVec4(from.x + (count * (to.x - from.x) / 100),from.y + (count * (to.y - from.y) / 100),from.z + (count * (to.z - from.z) / 100),from.w + (count * (to.w - from.w) / 100)), true end; return (timer > duration) and to or from, false
end

return function(name, hint_text, flags, buffer, color, text_color, width, colorInactive)
    imgui.SetCursorPosY(imgui.GetCursorPos().y + (imgui.CalcTextSize(hint_text).y * 0.7))
    if UI_BETTERINPUT == nil then UI_BETTERINPUT = {} end
    if not UI_BETTERINPUT[name] then UI_BETTERINPUT[name] = {buffer = buffer or imgui.new.char[256](''), width = nil, hint = { pos = nil, old_pos = nil, scale = nil }, color = colorInactive or imgui.GetStyle().Colors[imgui.Col.TextDisabled], old_color = colorInactive or imgui.GetStyle().Colors[imgui.Col.TextDisabled], active = {false, nil}, inactive = {true, nil}} end

    local pool = UI_BETTERINPUT[name]
    if color == nil then color = imgui.GetStyle().Colors[imgui.Col.Text] end
    if width == nil then
        pool["width"] = imgui.CalcTextSize(hint_text).x + 50
        if pool["width"] < 150 then
            pool["width"] = 150
        end
    else
        pool["width"] = width
    end

    if pool["hint"]["scale"] == nil then pool["hint"]["scale"] = 1.0 end
    if pool["hint"]["pos"] == nil then pool["hint"]["pos"] = imgui.ImVec2(imgui.GetCursorPos().x, imgui.GetCursorPos().y) end
    if pool["hint"]["old_pos"] == nil then pool["hint"]["old_pos"] = imgui.GetCursorPos().y end
    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(1, 1, 1, 0))
    imgui.PushStyleColor(imgui.Col.Text, text_color or imgui.ImVec4(1, 1, 1, 1))
    imgui.PushStyleColor(imgui.Col.TextSelectedBg, color)
    imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(0, imgui.GetStyle().FramePadding.y))
    imgui.PushItemWidth(pool["width"])
    local draw_list = imgui.GetWindowDrawList()
    draw_list:AddLine(
        imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
        imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
        imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + pool["width"],
        imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
        imgui.GetColorU32Vec4(imgui.ImVec4(pool["color"].x, pool["color"].y, pool["color"].z, pool["color"].w)), 2.0
    )

    local input = imgui.InputText("##" .. name, pool["buffer"], ffi.sizeof(pool["buffer"]), flags or 0)
    if not imgui.IsItemActive() then
        if pool["inactive"][2] == nil then pool["inactive"][2] = os.clock() end
        pool["inactive"][1] = true
        pool["active"][1] = false
        pool["active"][2] = nil
    elseif imgui.IsItemActive() or imgui.IsItemClicked() then
        pool["inactive"][1] = false
        pool["inactive"][2] = nil
        if pool["active"][2] == nil then pool["active"][2] = os.clock() end
        pool["active"][1] = true
    end
    if pool["inactive"][1] and #ffi.string(pool["buffer"]) == 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 1.0, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"], pool["inactive"][2], 0.25)
        
    elseif pool["inactive"][1] and #ffi.string(pool["buffer"]) > 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["inactive"][2], 0.25)

    elseif pool["active"][1] and #ffi.string(pool["buffer"]) == 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)

    elseif pool["active"][1] and #ffi.string(pool["buffer"]) > 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)
    end
    imgui.SetWindowFontScale(pool["hint"]["scale"])
    draw_list:AddText(
        imgui.ImVec2(pool["hint"]["pos"].x + imgui.GetWindowPos().x + imgui.GetStyle().FramePadding.x,pool["hint"]["pos"].y + imgui.GetWindowPos().y + imgui.GetStyle().FramePadding.y),
        imgui.GetColorU32Vec4(imgui.ImVec4(pool["color"].x, pool["color"].y, pool["color"].z, pool["color"].w)),
        hint_text
    )
    imgui.SetWindowFontScale(1.0)
    imgui.PopItemWidth()
    imgui.PopStyleColor(3)
    imgui.PopStyleVar()
    return input
end