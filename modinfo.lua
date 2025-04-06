name = "󰀮󰀏 彩虹光环 󰀏󰀮"
description = [[

󰀮󰀏夜幕降临，绚烂的彩虹光环将笼罩你的周围，为你带来温暖和希望！

󰀮󰀏夜幕降临了，不要灰心，我会永远守护在你身边，直到黎明！


]]
author = "凌"
version = "1.0.2"

-- 兼容性
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

-- 客户端与服务端标记
client_only_mod = false
all_clients_require_mod = true

-- 图标
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- 模组标签
server_filter_tags = {
    "buff",
    "rainbow_halo",
    "彩虹光环",
    "凌"
}

-- 配置选项
configuration_options = {
    {
        name = "LIGHT_RADIUS",
        label = "光环半径",
        options = {
            {description = "小", data = 1.5},
            {description = "中", data = 2},
            {description = "大", data = 3},
            {description = "超大", data = 4},
            {description = "巨大", data = 5},
            {description = "豪华", data = 6},
            {description = "天际", data = 7},
        },
        default = 6,
    },
    {
        name = "COLOR_CHANGE_SPEED",
        label = "颜色变换速度",
        options = {
            {description = "超级静止", data = 10, hover = "几乎无法察觉的变化"},
            {description = "静止如画", data = 8, hover = "仿佛时间凝固"},
            {description = "缓如星移", data = 6, hover = "如同星辰变换"},
            {description = "轻柔舒缓", data = 4, hover = "非常和谐的变换"},
            {description = "最慢", data = 3, hover = "大幅度减少闪烁感"},
            {description = "极慢", data = 2, hover = "减少闪烁感"},
            {description = "慢", data = 1.5, hover = "默认设置"},
            {description = "中", data = 1},
            {description = "快", data = 0.5},
        },
        default = 1.5,
    },
    {
        name = "LIGHT_INTENSITY",
        label = "光环亮度",
        options = {
            {description = "阴暗", data = 0.5, hover = "阴暗的氛围感"},
            {description = "暗", data = 0.5, hover = "氛围感"},
            {description = "中", data = 0.8, hover = "球体"},
            {description = "亮", data = 1,   hover = "立方体"},
        },
        default = 0.5,
    },
    {
        name = "SHOW_NIGHT_MESSAGE",
        label = "显示守护消息",
        options = {
            {description = "开启", data = true, hover = "夜晚降临时显示守护消息"},
            {description = "关闭", data = false, hover = "不显示消息"},
        },
        default = true,
    },
    {
        name = "ENABLE_DEBUG_LOG",
        label = "调试日志输出",
        options = {
            {description = "开启", data = true, hover = "输出调试日志信息"},
            {description = "关闭", data = false, hover = "不输出调试日志"},
        },
        default = false,
    }
} 