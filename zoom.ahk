#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force

SendMode "Input"
CoordMode "Mouse", "Screen"
#HotIf WinActive("ahk_exe ck3.exe")

; =============================================
;          热键定义
; =============================================

; --- 平滑缩放 (默认) ---
NumpadMult::ZoomIn()     ; 默认调用 ZoomIn(true)
NumpadDiv::ZoomOut()     ; 默认调用 ZoomOut(true)

; --- 匀速缩放 (按住Ctrl) ---
^NumpadMult::ZoomIn(false)
^NumpadDiv::ZoomOut(false)


; =============================================
;          缩放
; =============================================

; --- 匀速模式参数 ---
global scrollInterval := 100 
global scrollmaxtime := 5000 

; --- 平滑模式参数 ---
global smoothZoomDuration := 2000
global minSmoothZoomInterval := 30
global maxSmoothZoomInterval := 100

; --- 统一状态变量 ---
global currentZoomState := "none"
global smoothZoomStartTime := 0

ZoomIn(isSmooth := true)
{
    global currentZoomState, scrollInterval, scrollmaxtime, smoothZoomStartTime

    local previousState := currentZoomState
    StopZooming()

    if (previousState != "out")
    {
        currentZoomState := "out"
        if (isSmooth)
        {
            smoothZoomStartTime := A_TickCount
            SmoothZoomEngine()
        }
        else
        {
            SetTimer(ScrollUpAction, scrollInterval)
            SetTimer(StopZooming, -scrollmaxtime)
        }
    }
}

ZoomOut(isSmooth := true)
{
    global currentZoomState, scrollInterval, scrollmaxtime, smoothZoomStartTime
    
    local previousState := currentZoomState
    StopZooming()

    if (previousState != "in")
    {
        currentZoomState := "in"
        if (isSmooth)
        {
            smoothZoomStartTime := A_TickCount
            SmoothZoomEngine()
        }
        else
        {
            SetTimer(ScrollDownAction, scrollInterval)
            SetTimer(StopZooming, -scrollmaxtime)
        }
    }
}


; --- 匀速模式的执行函数 ---
ScrollDownAction() => Send("{WheelDown}")
ScrollUpAction() => Send("{WheelUp}")


; --- 平滑模式的执行引擎 ---
SmoothZoomEngine()
{
    global currentZoomState, smoothZoomStartTime, smoothZoomDuration, minSmoothZoomInterval, maxSmoothZoomInterval

    if (currentZoomState = "none")
    {
        return
    }

    if (currentZoomState = "in")
    {
        Send("{WheelDown}")
    }
    else
    {
        Send("{WheelUp}")
    }

    local elapsedTime := A_TickCount - smoothZoomStartTime
    if (elapsedTime >= smoothZoomDuration) {
        StopZooming()
        return
    }
    local progress := elapsedTime / smoothZoomDuration
    local easedProgress := EaseOutQuad(progress)
    local nextInterval := Round(minSmoothZoomInterval + easedProgress * (maxSmoothZoomInterval - minSmoothZoomInterval))

    SetTimer(SmoothZoomEngine, -nextInterval)
}


; --- 统一的停止函数 ---
StopZooming()
{
    global currentZoomState
    SetTimer(ScrollDownAction, 0)
    SetTimer(ScrollUpAction, 0)
    SetTimer(SmoothZoomEngine, 0)
    currentZoomState := "none"
}

; --- 公用函数 ---
global PI := 3.141592653589793
EaseInOut(p) => -(Cos(PI * p) - 1) / 2
EaseOutQuad(p) => p * (2 - p)