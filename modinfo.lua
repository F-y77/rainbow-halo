name = "彩虹光环"
description = "在你的周围添加一个不断变换颜色的彩虹光环！"
author = "凌"
version = "1.0.0"

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
    "light",
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
            {description = "中", data = 2, hover = "默认设置"},
            {description = "大", data = 3},
            {description = "超大", data = 4}
        },
        default = 2,
    },
    {
        name = "COLOR_CHANGE_SPEED",
        label = "颜色变换速度",
        options = {
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
            {description = "暗", data = 0.5},
            {description = "中", data = 0.8, hover = "默认设置"},
            {description = "亮", data = 1},
        },
        default = 0.3,
    }
} 