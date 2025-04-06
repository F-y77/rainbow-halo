GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 添加自定义资源
Assets = {
    Asset("ANIM", "anim/halo.zip"), -- 添加您的自定义动画文件
}

-- 获取配置选项
local LIGHT_RADIUS = GetModConfigData("LIGHT_RADIUS") 
local COLOR_CHANGE_SPEED = GetModConfigData("COLOR_CHANGE_SPEED")  
local LIGHT_INTENSITY = GetModConfigData("LIGHT_INTENSITY") 

-- 存储每个玩家的光源和任务
local player_lights = {}

-- 声明RemoveRainbowHalo函数(将在后面定义)
local RemoveRainbowHalo

-- 为玩家添加彩虹光环
local function AddRainbowHalo(player)
    -- 如果玩家已经有光环，先移除
    if player_lights[player] then
        RemoveRainbowHalo(player)
    end
    
    -- 初始化player_lights表
    player_lights[player] = {}
    
    -- 创建基础光源（提供实际的光照效果）
    local light = SpawnPrefab("minerhatlight")
    if light then
        light.entity:SetParent(player.entity)
        light.Light:SetRadius(LIGHT_RADIUS)
        light.Light:SetFalloff(0.9) 
        light.Light:SetIntensity(LIGHT_INTENSITY)
        light.Light:EnableClientModulation(false) -- 确保白天可见
        
        -- 保存光源引用
        player_lights[player].light = light
        
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
        
        -- 创建自定义光环特效
        local function CreateCustomHaloFX()
            -- 移除旧的FX(如果存在)
            if player_lights[player].fx and player_lights[player].fx:IsValid() then
                player_lights[player].fx:Remove()
            end
            
            -- 创建一个空的实体作为我们的自定义特效载体
            local newfx = CreateEntity()
            
            -- 添加必要的组件
            newfx.entity:AddTransform()
            newfx.entity:AddAnimState()
            newfx.entity:AddNetwork()
            
            -- 设置动画
            newfx.AnimState:SetBank("halo") -- 设置您的动画bank名称
            newfx.AnimState:SetBuild("halo") -- 设置您的动画build名称
            newfx.AnimState:PlayAnimation("halo", true) -- 假设您的动画文件有halo动画
            
            -- 添加标签，标记为特效
            newfx:AddTag("FX")
            newfx:AddTag("NOCLICK")
            
            -- 设置特效位置和大小
            newfx.entity:SetParent(player.entity)
            newfx.Transform:SetPosition(0, 0.5, 0) -- 调整高度
            newfx.Transform:SetScale(1.0, 1.0, 1.0) -- 调整大小
            
            -- 设置当前颜色
            local color = colors[color_index]
            newfx.AnimState:SetMultColour(color.r, color.g, color.b, 0.9)
            
            -- 确保特效不会被保存
            newfx.persists = false
            
            -- 保存引用
            player_lights[player].fx = newfx
            
            return newfx
        end
        
        -- 立即创建第一个特效
        CreateCustomHaloFX()
        
        -- 每秒检查特效是否还存在，如果不存在则重新创建
        player_lights[player].checktask = TheWorld:DoPeriodicTask(1, function()
            if not (player_lights[player] and player_lights[player].fx and player_lights[player].fx:IsValid()) then
                CreateCustomHaloFX()
            else 
                -- 确保特效正在播放正确的动画
                if player_lights[player].fx.AnimState and 
                   not player_lights[player].fx.AnimState:IsCurrentAnimation("halo") then
                    player_lights[player].fx.AnimState:PlayAnimation("halo", true)
                end
            end
        end)
        
        -- 创建颜色变换任务，非常缓慢
        player_lights[player].colortask = TheWorld:DoPeriodicTask(COLOR_CHANGE_SPEED, function()
            color_index = color_index % #colors + 1
            local color = colors[color_index]
            
            -- 设置光源颜色
            if light and light:IsValid() then
                light.Light:SetColour(color.r, color.g, color.b)
            end
            
            -- 设置当前特效的颜色(如果存在)
            if player_lights[player].fx and player_lights[player].fx:IsValid() and 
               player_lights[player].fx.AnimState then
                player_lights[player].fx.AnimState:SetMultColour(color.r, color.g, color.b, 0.9)
            end
        end)
    end
end

-- 移除玩家的彩虹光环
RemoveRainbowHalo = function(player)
    if player_lights[player] then
        if player_lights[player].colortask then
            player_lights[player].colortask:Cancel()
        end
        
        if player_lights[player].checktask then
            player_lights[player].checktask:Cancel()
        end
        
        if player_lights[player].light and player_lights[player].light:IsValid() then
            player_lights[player].light:Remove()
        end
        
        if player_lights[player].fx and player_lights[player].fx:IsValid() then
            player_lights[player].fx:Remove()
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
        
        -- 监听事件，确保光环在各种情况下都正确显示
        inst:ListenForEvent("death", function()
            RemoveRainbowHalo(inst)
        end)
        
        inst:ListenForEvent("respawnfromghost", function()
            inst:DoTaskInTime(1, function()
                AddRainbowHalo(inst)
            end)
        end)
        
        inst:ListenForEvent("onremove", function()
            RemoveRainbowHalo(inst)
        end)
    end
end) 