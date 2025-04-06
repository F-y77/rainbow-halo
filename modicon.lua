-- 使用饥荒内置的图标制作工具
local function CreateModIcon()
    local icon = {
        name = "modicon",
        atlas = "images/inventoryimages/rainbow_halo.xml",
        tex = "rainbow_halo.tex",
        width = 128,
        height = 128
    }
    
    return icon
end

return CreateModIcon() 