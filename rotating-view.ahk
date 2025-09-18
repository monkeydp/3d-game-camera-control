#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================
;          全局设定
; =============================================
SendMode "Event"
CoordMode "Mouse", "Screen"

; =============================================
;          【核心配置区】 - 已更新为您的参数
; =============================================
global orbit_step_x := 3       ; 每次向【右】移动的像素距离。
global orbit_step_y := -0.3    ; 每次向【下】移动的像素距离。
global orbit_step_delay := 20  ; 每次移动的延迟时间(毫秒)。
global orbit_timeout := 60     ; 自动停止的超时时间（秒）。
global edge_margin := [100]    ; 屏幕边缘安全距离。

; 到达边缘后，延迟多久松开右键（秒）。0 为立即松开。
global release_delay_on_edge := 0.5

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
        StopOrbit()
    } else {
        StartOrbit()
    }
}

StartOrbit() {
    global isOrbiting, orbit_step_delay, orbit_timeout, g_accumulated_y
    isOrbiting := true
    g_accumulated_y := 0.0
    Click "Right Down"
    SetTimer(OrbitAction, orbit_step_delay)
    SetTimer(StopOrbit, -(orbit_timeout * 1000))
}

StopOrbit() {
    global isOrbiting
    if (!isOrbiting) {
        return
    }
    isOrbiting := false
    SetTimer(OrbitAction, 0)
    SetTimer(StopOrbit, 0)
    Click "Right Up"
}

OrbitAction() {
    global orbit_step_x, orbit_step_y, g_parsed_margins, release_delay_on_edge, g_accumulated_y
    MouseGetPos(&current_x, &current_y)

    if ( (current_x + orbit_step_x >= A_ScreenWidth - g_parsed_margins.right)
      || (current_x + orbit_step_x <= g_parsed_margins.left)
      || (current_y + orbit_step_y >= A_ScreenHeight - g_parsed_margins.bottom)
      || (current_y + orbit_step_y <= g_parsed_margins.top) )
    {
        SetTimer(OrbitAction, 0)
        if (release_delay_on_edge == 0) {
            StopOrbit()
        } else {
            SetTimer(StopOrbit, -(release_delay_on_edge * 1000))
        }
    }
    else
    {
        local y_move_this_tick := 0
        g_accumulated_y += orbit_step_y
        if (Abs(g_accumulated_y) >= 1) {
            ; 【核心修正】 使用 Integer() 代替 Trunc() 来避免警告
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