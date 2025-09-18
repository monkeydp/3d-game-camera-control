#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================
;          全局设定
; =============================================
SendMode "Event"
CoordMode "Mouse", "Screen"

; =============================================
;          【核心配置区】 - 在这里调整所有参数
; =============================================
global orbit_step_x := 2       ; 每次向【右】移动的像素距离。
global orbit_step_y := -0.3    ; 每次向【下】移动的像素距离。
global orbit_step_delay := 20  ; 每次移动的延迟时间(毫秒)。
global edge_margin := [100]    ; 屏幕边缘安全距离。

; 【新增】主动环绕时长（秒）。到达这个时间后，会像碰到边缘一样停止。
; 设置为 0 或一个非常大的数 (如 999) 来禁用它。
global orbit_duration := 25.5

; 到达边缘或达到主动时长后，延迟多久松开右键（秒）。0 为立即松开。
global release_delay_on_edge := 1

; 这是一个【安全保险】，用于防止脚本意外失控。应大于 orbit_duration。
global orbit_timeout := 60

; =============================================
;          全局变量 (请勿修改)
; =============================================
global isOrbiting := false
global g_parsed_margins
global g_accumulated_y := 0.0

; =============================================
;          初始化
; =============================================
ParseMargins()

; =============================================
;          热键定义
; =============================================
#HotIf WinActive("ahk_exe ck3.exe")

NumpadAdd::ToggleOrbit()
^NumpadAdd::ForceReload()

~RButton:: {
    global isOrbiting
    if (isOrbiting) {
        StopOrbit()
    }
}

#HotIf


; =============================================
;          核心功能函数
; =============================================

ToggleOrbit() {
    global isOrbiting
    if (isOrbiting) {
        StopOrbit() ; 手动停止
    } else {
        StartOrbit()
    }
}

StartOrbit() {
    global isOrbiting, orbit_step_delay, orbit_timeout, orbit_duration, g_accumulated_y
    isOrbiting := true
    g_accumulated_y := 0.0
    Click "Right Down"
    
    SetTimer(OrbitAction, orbit_step_delay)
    
    ; 启动【安全超时】定时器
    SetTimer(StopOrbit, -(orbit_timeout * 1000))
    
    ; 如果设置了主动时长，则启动【主动时长】定时器
    if (orbit_duration > 0) {
        SetTimer(StopOrbitByDuration, -(orbit_duration * 1000))
    }
}

/**
 * 【完全停止】函数，用于手动停止、右键单击停止和安全超时。
 * 它会立即松开右键。
 */
StopOrbit() {
    global isOrbiting
    if (!isOrbiting) {
        return
    }
    isOrbiting := false
    SetTimer(OrbitAction, 0)
    SetTimer(StopOrbit, 0)
    SetTimer(StopOrbitByDuration, 0) ; 确保也关闭了主动时长定时器
    Click "Right Up"
}

/**
 * 【新增】因达到【主动时长】或【碰到边缘】而停止的函数。
 * 它会根据 release_delay_on_edge 的值来决定何时松开右键。
 */
StopOrbitByDuration() {
    global release_delay_on_edge

    ; 步骤 1: 立刻停止移动
    SetTimer(OrbitAction, 0)

    ; 步骤 2: 根据延时参数决定何时松开右键
    if (release_delay_on_edge == 0) {
        StopOrbit() ; 如果延时为 0，则立即调用完全停止函数
    } else {
        ; 否则，启动一个新的定时器，在指定秒数后调用完全停止函数
        SetTimer(StopOrbit, -(release_delay_on_edge * 1000))
    }
}


OrbitAction() {
    global orbit_step_x, orbit_step_y, g_parsed_margins, g_accumulated_y
    MouseGetPos(&current_x, &current_y)

    if ( (current_x + orbit_step_x >= A_ScreenWidth - g_parsed_margins.right)
      || (current_x + orbit_step_x <= g_parsed_margins.left)
      || (current_y + orbit_step_y >= A_ScreenHeight - g_parsed_margins.bottom)
      || (current_y + orbit_step_y <= g_parsed_margins.top) )
    {
        ; 如果碰到边缘，调用与达到主动时长相同的逻辑
        StopOrbitByDuration()
    }
    else
    {
        local y_move_this_tick := 0
        g_accumulated_y += orbit_step_y
        if (Abs(g_accumulated_y) >= 1) {
            y_move_this_tick := Integer(g_accumulated_y)
            g_accumulated_y -= y_move_this_tick
        }
        MouseMove(orbit_step_x, y_move_this_tick, 0, "Relative")
    }
}

ForceReload() {
    StopOrbit()
    Sleep(50)
    Reload()
}

ParseMargins() {
    global edge_margin, g_parsed_margins
    local top, right, bottom, left
    if IsObject(edge_margin) {
        switch edge_margin.Length {
            case 1:
                top := right := bottom := left := edge_margin[1]
            case 2:
                top    := bottom := edge_margin[1]
                right  := left   := edge_margin[2]
            case 3:
                top    := edge_margin[1]
                right  := left   := edge_margin[2]
                bottom := edge_margin[3]
            case 4:
                top    := edge_margin[1]
                right  := edge_margin[2]
                bottom := edge_margin[3]
                left   := edge_margin[4]
            default:
                top := right := bottom := left := 50
        }
    } else {
        top := right := bottom := left := 50
    }
    g_parsed_margins := {top: top, right: right, bottom: bottom, left: left}
}