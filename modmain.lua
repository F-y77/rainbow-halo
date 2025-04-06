GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 获取配置选项
local LIGHT_RADIUS = GetModConfigData("LIGHT_RADIUS") or 2
local COLOR_CHANGE_SPEED = GetModConfigData("COLOR_CHANGE_SPEED") or 3.0 -- 非常缓慢的颜色变换
local LIGHT_INTENSITY = GetModConfigData("LIGHT_INTENSITY") or 0.7 -- 降低默认亮度

-- 存储每个玩家的光源和任务
local player_lights = {}

-- 为玩家添加彩虹光环
local function AddRainbowHalo(player)
    -- 如果玩家已经有光环，先移除
    if player_lights[player] then
        RemoveRainbowHalo(player)
    end
    
    -- 创建光源
    local light = SpawnPrefab("minerhatlight")
    if light then
        light.entity:SetParent(player.entity)
        light.Light:SetRadius(LIGHT_RADIUS)
        light.Light:SetFalloff(0.9) -- 尽可能让光环更圆润
        light.Light:SetIntensity(LIGHT_INTENSITY)
        light.Light:EnableClientModulation(false) -- 确保白天可见
        
        -- 设置颜色数组
        local colors = {
            {r=1, g=0, b=0},   -- 红
            {r=1, g=0.5, b=0}, -- 橙
            {r=1, g=1, b=0},   -- 黄
            {r=0, g=1, b=0},   -- 绿
            {r=0, g=0.5, b=1}, -- 青
            {r=0, g=0, b=1},   -- 蓝
            {r=0.5, g=0, b=0.5} -- 紫
        }
        
        -- 初始化颜色索引
        local color_index = 1
        
        -- 创建颜色变换任务，非常缓慢
        local color_task = TheWorld:DoPeriodicTask(COLOR_CHANGE_SPEED, function()
            if light and light:IsValid() then
                color_index = color_index % #colors + 1
                local color = colors[color_index]
                light.Light:SetColour(color.r, color.g, color.b)
            end
        end)
        
        -- 保存光源和任务引用
        player_lights[player] = {
            light = light,
            task = color_task
        }
    end
end

-- 移除玩家的彩虹光环
local function RemoveRainbowHalo(player)
    if player_lights[player] then
        if player_lights[player].task then
            player_lights[player].task:Cancel()
        end
        
        if player_lights[player].light and player_lights[player].light:IsValid() then
            player_lights[player].light:Remove()
        end
        
        player_lights[player] = nil
    end
end

-- 当玩家加入游戏或者创建角色时添加光环
AddPlayerPostInit(function(inst)
    if TheWorld.ismastersim then
        -- 延迟一秒添加光环，确保玩家已完全加载
        inst:DoTaskInTime(1, function()
            AddRainbowHalo(inst)
        end)
        
        -- 监听玩家死亡事件，移除光环
        inst:ListenForEvent("death", function()
            RemoveRainbowHalo(inst)
        end)
        
        -- 监听玩家复活事件，重新添加光环
        inst:ListenForEvent("respawnfromghost", function()
            inst:DoTaskInTime(1, function()
                AddRainbowHalo(inst)
            end)
        end)
        
        -- 监听玩家离开事件，清理资源
        inst:ListenForEvent("onremove", function()
            RemoveRainbowHalo(inst)
        end)
    end
end) 