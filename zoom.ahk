#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force

SendMode "Input"
CoordMode "Mouse", "Screen"
#HotIf WinActive("ahk_exe ck3.exe")

; =============================================
;          持续缩放
; =============================================

; --- 按下 小键盘“*” 放大 ---
NumpadMult::
{
    ZoomIn()
}

; --- 按下 小键盘“/” 缩小 ---
NumpadDiv::
{
    ZoomOut()
}


; ######################################################################
; ##                                                                  ##
; ##                       核心功能函数                               ##
; ##                                                                  ##
; ######################################################################

global scrollInterval := 100 
global scrollmaxtime := 5000 

; 这个变量现在用来跟踪当前的滚动方向
; 可能的值: "none", "in", "out"
global currentZoomState := "none"

ZoomIn()
{
    global currentZoomState

    local previousState := currentZoomState
    StopZooming()

    if (previousState != "out")
    {
        currentZoomState := "out"
        SetTimer ScrollUpAction, scrollInterval
        SetTimer StopZooming, -scrollmaxtime
    }
}

ZoomOut()
{
    global currentZoomState
    
    ; 核心逻辑:
    ; 1. 先记录下当前是什么状态。
    ; 2. 立即停止所有当前的滚动。
    ; 3. 如果之前的状态不是“正在放大”，那么就开始“放大”。
    ;    (如果之前是“正在缩小”，这会无缝切换；如果之前是“停止”，这会直接启动)
    ; 4. 如果之前的状态就是“正在放大”，那么按第二次就意味着停止，此时 StopZooming() 已经完成任务。
    
    local previousState := currentZoomState
    StopZooming()

    if (previousState != "in")
    {
        currentZoomState := "in"
        SetTimer ScrollDownAction, scrollInterval
        SetTimer StopZooming, -scrollmaxtime
    }
}

ScrollDownAction()
{
    Send "{WheelDown}"
}

ScrollUpAction()
{
    Send "{WheelUp}"
}

StopZooming()
{
    global currentZoomState
    SetTimer ScrollDownAction, 0
    SetTimer ScrollUpAction, 0
    currentZoomState := "none"
}

MouseMove2center()
{
    MouseMove A_ScreenWidth / 2, A_ScreenHeight / 2, 0
}
