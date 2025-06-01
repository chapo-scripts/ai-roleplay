local fontsBase85 = require('ui.resource.fonts');
local usedIcons = {

};

return {
    init = function()
        imgui.GetIO().Fonts:Clear()
        UI.font = {}

        local list = {
            'brain',
            'message',
            'bubble-text',
            'home',
            'settings',
            'caret-down',
            'send-2',
            'heart',
            'check',
            'cancel'
        };

        local builder = imgui.ImFontGlyphRangesBuilder()
        local range = imgui.ImVector_ImWchar()

        builder:AddRanges(imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
        builder:AddText("‚„…†‡ˆ‰‹‘’“”•–-™›¹")
        builder:BuildRanges(range)

        local config = imgui.ImFontConfig();
        local iconRanges = imgui.ImVector_ImWchar();
        for _, b in ipairs(list) do builder:AddText(ti(b)) end
        builder:BuildRanges(iconRanges);
        config.MergeMode = true;
        config.PixelSnapH = true;
        config.GlyphOffset.y = 1;

        for name, fontBase85 in pairs(fontsBase85) do
            for _, size in ipairs({ 14, 16, 18, 20, 25, 30, 50 }) do
                UI.font[size] = {};
                -->> Font
                UI.font[size][name] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fontBase85, size, nil, range[0].Data)
                -->> Icons
                UI.font[size][name] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ti.get_font_data_base85('solid'), size, config, iconRanges[0].Data);
            end
        end

        imgui.InvalidateFontsTexture()
    end
};