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
global orbit_step_x := 5       ; 每次移动的【像素距离】。
global orbit_step_delay := 20  ; 每次移动的【延迟时间】(毫秒)。
global edge_margin := 100      ; 屏幕边缘的安全距离（像素）。
global orbit_timeout := 60     ; 自动停止的超时时间（秒）。

; =============================================
;          全局变量
; =============================================
global isOrbiting := false

; =============================================
;          热键定义
; =============================================
#HotIf WinActive("ahk_exe ck3.exe")

NumpadAdd::ToggleOrbit()
^NumpadAdd::ForceReload()

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
    global isOrbiting, orbit_step_delay, orbit_timeout
    isOrbiting := true
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
    global orbit_step_x, edge_margin
    MouseGetPos(&current_x, &current_y)
    if (current_x + orbit_step_x >= A_ScreenWidth - edge_margin)
    {
        SetTimer(OrbitAction, 0)
    }
    else
    {
        MouseMove(orbit_step_x, 0, 0, "Relative")
    }
}

ForceReload() {
    StopOrbit()
    Sleep(50)
    Reload()
}