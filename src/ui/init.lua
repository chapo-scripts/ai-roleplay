local imgui = require('mimgui');
local encoding = require('encoding');
encoding.default = 'CP1251';
local u8 = encoding.UTF8;

local window = imgui.new.bool(true)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil;
    local style = imgui.GetStyle();
    style.WindowRounding = 5;
    style.WindowPadding = imgui.ImVec2(10, 10);
    style.WindowBorderSize = 0;

    local colors = style.Colors;
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.07, 0.07, 0.07, 1);
    -- colors[imgui.Col.W]
end);

local page = 1;

imgui.OnFrame(
    function() return window[0] end,
    function(thisWindow)
        local res = imgui.ImVec2(getScreenResolution());
        local size = imgui.ImVec2(700, 450);
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver);
        if (imgui.Begin('Main Window', window, imgui.WindowFlags.NoDecoration)) then
            
            imgui.Text(tostring(API.error))
            for k, v in pairs(API.models) do
                imgui.Text(tostring(v.name))
            end
        end
        imgui.End();
    end
);