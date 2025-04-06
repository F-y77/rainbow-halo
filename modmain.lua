GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 添加自定义资源
Assets = {
    Asset("ANIM", "anim/halo.zip"), -- 添加您的自定义动画文件
}

-- 获取配置选项
local LIGHT_RADIUS = GetModConfigData("LIGHT_RADIUS") or 2
local COLOR_CHANGE_SPEED = GetModConfigData("COLOR_CHANGE_SPEED") or 3.0
local LIGHT_INTENSITY = GetModConfigData("LIGHT_INTENSITY") or 0.7
local SHOW_NIGHT_MESSAGE = GetModConfigData("SHOW_NIGHT_MESSAGE") -- 是否显示夜晚守护消息
local ENABLE_DEBUG_LOG = GetModConfigData("ENABLE_DEBUG_LOG") -- 是否输出调试日志

-- 存储每个玩家的光源和任务
local player_lights = {}

-- 声明RemoveRainbowHalo函数(将在后面定义)
local RemoveRainbowHalo

-- 夜晚守护消息
local NIGHT_MESSAGE = "󰀮󰀏夜幕降临了，不要灰心，我会永远守护在你身边，直到黎明！"

-- 打印调试信息
local function DebugPrint(msg)
    if ENABLE_DEBUG_LOG then
        print("[彩虹光环] " .. tostring(msg))
    end
end

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
        
        -- 默认在白天禁用光源
        if not TheWorld.state.isnight then
            light.Light:Enable(false)
        else
            DebugPrint("现在是夜晚，启用光源")
        end
        
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
            DebugPrint("正在创建光环特效")
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
            newfx.AnimState:PlayAnimation("halo", true) -- 使用halo作为动画名称
            
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
            
            -- 确保网络同步
            newfx.entity:SetPristine()
            
            -- 保存引用
            player_lights[player].fx = newfx
            
            return newfx
        end
        
        -- 显示夜晚守护消息
        local function ShowNightMessage()
            if SHOW_NIGHT_MESSAGE and player and player.components and player.components.talker then
                player.components.talker:Say(NIGHT_MESSAGE)
            end
        end
        
        -- 立即检查是否是夜晚，如果是则创建特效
        if TheWorld.state.isnight then
            DebugPrint("初始化时检测到夜晚，创建光环")
            CreateCustomHaloFX()
            -- 如果是夜晚且玩家刚加入，显示守护消息
            ShowNightMessage()
        else
            DebugPrint("初始化时不是夜晚，不创建光环")
        end
        
        -- 监听日夜变化，只在夜晚显示光环
        player_lights[player].phasetask = TheWorld:ListenForEvent("phasechanged", function(world, data)
            -- 安全地检查data和newphase值
            if data and data.newphase then
                DebugPrint("检测到相位变化: " .. tostring(data.newphase))
                
                if data.newphase == "night" then
                    -- 夜晚开始，创建光环
                    DebugPrint("夜晚开始，创建光环")
                    if not player_lights[player].fx or not player_lights[player].fx:IsValid() then
                        CreateCustomHaloFX()
                    end
                    
                    -- 显示光源
                    if player_lights[player].light and player_lights[player].light:IsValid() then
                        player_lights[player].light.Light:Enable(true)
                    end
                    
                    -- 显示夜晚守护消息
                    ShowNightMessage()
                else
                    -- 夜晚结束，移除光环
                    DebugPrint("夜晚结束，移除光环")
                    if player_lights[player].fx and player_lights[player].fx:IsValid() then
                        player_lights[player].fx:Remove()
                        player_lights[player].fx = nil
                    end
                    
                    -- 隐藏光源
                    if player_lights[player].light and player_lights[player].light:IsValid() then
                        player_lights[player].light.Light:Enable(false)
                    end
                end
            else
                -- data或data.newphase为nil的情况
                DebugPrint("phasechanged事件触发，但数据无效")
                
                -- 直接检查当前是否为夜晚
                local isNightNow = TheWorld.state.isnight
                DebugPrint("直接检查当前状态: " .. (isNightNow and "夜晚" or "非夜晚"))
                
                -- 根据当前状态更新特效
                if isNightNow then
                    if not player_lights[player].fx or not player_lights[player].fx:IsValid() then
                        CreateCustomHaloFX()
                    end
                    
                    if player_lights[player].light and player_lights[player].light:IsValid() then
                        player_lights[player].light.Light:Enable(true)
                    end
                    
                    -- 显示夜晚守护消息
                    ShowNightMessage()
                else
                    if player_lights[player].fx and player_lights[player].fx:IsValid() then
                        player_lights[player].fx:Remove()
                        player_lights[player].fx = nil
                    end
                    
                    if player_lights[player].light and player_lights[player].light:IsValid() then
                        player_lights[player].light.Light:Enable(false)
                    end
                end
            end
        end)
        
        -- 添加一个定期检查夜晚状态的任务，以防phasechanged事件未触发
        player_lights[player].checktask = TheWorld:DoPeriodicTask(1, function()
            -- 如果是夜晚但没有特效，则创建特效
            local wasNight = player_lights[player].isnight
            local isNightNow = TheWorld.state.isnight
            
            -- 保存当前夜晚状态
            player_lights[player].isnight = isNightNow
            
            if isNightNow then
                if not player_lights[player].fx or not player_lights[player].fx:IsValid() then
                    DebugPrint("周期性检查：是夜晚但没有特效，创建特效")
                    CreateCustomHaloFX()
                    
                    -- 确保光源开启
                    if player_lights[player].light and player_lights[player].light:IsValid() then
                        player_lights[player].light.Light:Enable(true)
                    end
                    
                    -- 如果刚变成夜晚，显示守护消息
                    if wasNight == false then
                        ShowNightMessage()
                    end
                end
            else
                -- 如果不是夜晚但有特效，则移除
                if player_lights[player].fx and player_lights[player].fx:IsValid() then
                    DebugPrint("周期性检查：不是夜晚但有特效，移除特效")
                    player_lights[player].fx:Remove()
                    player_lights[player].fx = nil
                    
                    -- 确保光源关闭
                    if player_lights[player].light and player_lights[player].light:IsValid() then
                        player_lights[player].light.Light:Enable(false)
                    end
                end
            end
        end)
        
        -- 创建颜色变换任务，只在夜晚有效
        player_lights[player].colortask = TheWorld:DoPeriodicTask(COLOR_CHANGE_SPEED, function()
            -- 计算下一个颜色索引
            color_index = color_index % #colors + 1
            local color = colors[color_index]
            
            -- 只在夜晚且光源存在时更新颜色
            if TheWorld.state.isnight then
                -- 设置光源颜色
                if player_lights[player].light and player_lights[player].light:IsValid() then
                    player_lights[player].light.Light:SetColour(color.r, color.g, color.b)
                end
                
                -- 设置当前特效的颜色(如果存在)
                if player_lights[player].fx and player_lights[player].fx:IsValid() and 
                   player_lights[player].fx.AnimState then
                    player_lights[player].fx.AnimState:SetMultColour(color.r, color.g, color.b, 0.9)
                end
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
        
        if player_lights[player].phasetask then
            player_lights[player].phasetask:Remove()
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
            DebugPrint("正在为玩家 " .. tostring(inst) .. " 添加彩虹光环")
            
            -- 调试输出当前时间状态
            if TheWorld.state.isnight then
                DebugPrint("当前是夜晚")
            else
                DebugPrint("当前不是夜晚")
            end
            
            AddRainbowHalo(inst)
        end)
        
        -- 监听事件，确保光环在各种情况下都正确显示
        inst:ListenForEvent("death", function()
            DebugPrint("玩家死亡，移除光环")
            RemoveRainbowHalo(inst)
        end)
        
        inst:ListenForEvent("respawnfromghost", function()
            DebugPrint("玩家复活，重新添加光环")
            inst:DoTaskInTime(1, function()
                AddRainbowHalo(inst)
            end)
        end)
        
        inst:ListenForEvent("onremove", function()
            DebugPrint("玩家移除，清理光环")
            RemoveRainbowHalo(inst)
        end)
    end
end) 