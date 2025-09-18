#Requires AutoHotkey v2.0
#SingleInstance Force

; 加载库
#include <AutoHotInterception>

SendMode "Input"
CoordMode "Mouse", "Screen"
#HotIf WinActive("ahk_exe ck3.exe")

Init(){
    MouseMove2center()
}


; =============================================
;          小键盘数字八向移动地图
; =============================================

; --- 全局变量和 AHI 初始化 ---
global AHI := AutoHotInterception()
global keyboardId := 1

; --- 【核心配置区】---
; 在这里定义所有你想要的重映射规则

; 1. 定义按键扫描码常量，让代码更易读
global SC_UP    := 328
global SC_RIGHT := 333
global SC_LEFT  := 331
global SC_DOWN  := 336

; 2. 定义小键盘数字键的扫描码
global NUMPAD_1 := 82
global NUMPAD_1 := 79
global NUMPAD_2 := 80
global NUMPAD_3 := 81
global NUMPAD_4 := 75
global NUMPAD_6 := 77
global NUMPAD_7 := 71
global NUMPAD_8 := 72
global NUMPAD_9 := 73

; 2. 定义小键盘其他按键
global NUMPAD_SUB := 74
global NUMPAD_ADD := 78
global NUMPAD_Milt := 55
global NUMPAD_DIV := 309


; 3. 创建映射表 (Map)
;    键 (Key) 是你要按下的原始按键
;    值 (Value) 是一个包含所有目标按键扫描码的数组 (Array)
global KeyMappings := Map(
    ; --- 对角线映射 (原有的) ---
    NUMPAD_1, [SC_LEFT, SC_DOWN],
    NUMPAD_3, [SC_RIGHT, SC_DOWN],
    NUMPAD_7, [SC_LEFT, SC_UP],
    NUMPAD_9, [SC_RIGHT, SC_UP],

    ; --- 上下左右映射 (新增的) ---
    NUMPAD_8, [SC_UP],
    NUMPAD_2, [SC_DOWN],
    NUMPAD_4, [SC_LEFT],
    NUMPAD_6, [SC_RIGHT]
)

; --- 【核心逻辑函数 ---
HandleRemap(triggerCode, state) {
    global keyboardId, AHI, KeyMappings
    targetKeys := KeyMappings[triggerCode]
    for keyCode in targetKeys {
        AHI.SendKeyEvent(keyboardId, keyCode, state)
    }
}


; --- 【主事件处理函数】 ---
KeyEvent(code, state) {
    global KeyMappings, keyboardId, AHI

    ; 【核心修改点】先检查当前窗口是不是 ck3.exe
    if (!WinActive("ahk_exe ck3.exe")) {
        ; 如果窗口不是 ck3.exe，或者按键不在映射表中，
        ; 就把按键原封不动地放行
        AHI.SendKeyEvent(keyboardId, code, state)
        return 0
    }
        
    ; 如果是 ck3.exe，再执行原来的映射逻辑
    if (KeyMappings.Has(code)) {
        HandleRemap(code, state)
        return 0 ; 拦截按键
    }
    else if (code == NUMPAD_SUB && state == 1) ; state == 1 表示按下
    {
        SetTimer Init, -1
        return 0 ; return 0 会阻止原始按键
    }

    AHI.SendKeyEvent(keyboardId, code, state)
    return 0
}
; -----------------------------------------------------------------
; 设置键盘拦截
AHI.SubscribeKeyboard(keyboardId, true, KeyEvent)

; =============================================
;          持续缩放
; =============================================

; --- 按下 小键盘“*” 放大 ---
NumpadMult::
{
    ;MouseMove2center()
    ZoomIn()
}

; --- 按下 小键盘“/” 缩小 ---
NumpadDiv::
{
    ;MouseMove2center()
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


; =============================================
;          鼠标当前位置移动到地图中心
; =============================================

global PI := 3.141592653589793
global isPanning := false

#MaxThreadsPerHotkey 2

Numpad5::
{
    ; --- 【核心修正】---
    ; 在热键内部声明我们要使用的是全局变量 isPanning
    global isPanning

    isPanning := !isPanning

    if (isPanning) {
        SmoothPanToCenter()
        isPanning := false
    }
}

EaseInOut(p) {
    global PI
    return -(Cos(PI * p) - 1) / 2
}

EaseOutCubic(p) {
    return 1 - (1 - p) ** 3
}

SmoothPanToCenter() {
    global isPanning

    overshootSteps := 35
    overshootDelay := 10
    overshootFactor := 1.3
    pauseDuration := 400
    settleSteps := 50
    settleDelay := 20

    MouseGetPos(&startX, &startY)
    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2
    totalMoveX := centerX - startX
    totalMoveY := centerY - startY
    overshootMouseX := Round(startX + totalMoveX * overshootFactor)
    overshootMouseY := Round(startY + totalMoveY * overshootFactor)
    finalMouseX := startX + totalMoveX
    finalMouseY := startY + totalMoveY
    
    Send "{MButton Down}"
    Sleep 20

    Loop overshootSteps {
        if (!isPanning) {
            Send "{MButton Up}"
            return
        }
        progress := EaseInOut(A_Index / overshootSteps)
        currentX := Round(startX + (overshootMouseX - startX) * progress)
        currentY := Round(startY + (overshootMouseY - startY) * progress)
        MouseMove(currentX, currentY, 0)
        Sleep overshootDelay
    }
    MouseMove(overshootMouseX, overshootMouseY, 0)

    Sleep pauseDuration

    if (!isPanning) {
        Send "{MButton Up}"
        return
    }

    Loop settleSteps {
        if (!isPanning) {
            Send "{MButton Up}"
            return
        }
        linearProgress := A_Index / settleSteps 
        easedProgress := EaseOutCubic(linearProgress)
        currentX := Round(overshootMouseX + (finalMouseX - overshootMouseX) * easedProgress)
        currentY := Round(overshootMouseY + (finalMouseY - overshootMouseY) * easedProgress)
        MouseMove(currentX, currentY, 0)
        Sleep settleDelay
    }
    MouseMove(finalMouseX, finalMouseY, 0)

    Send "{MButton Up}"
}


; =============================================
;          存储鼠标位置
; =============================================
global g_positions := []
global g_posFile := A_ScriptDir . "\pos.txt"
InitializeAndLoadPositions()

; =============================================
;          核心功能函数
; =============================================

HideToolTip() {
    ToolTip()
}

GetKeyAsIndex(key) {
    return Integer(key) + 1
}

GetIndexAsKey(index) {
    return index - 1
}

/**
 * 【已修正】初始化并从文件加载数据
 */
InitializeAndLoadPositions() {
    global g_positions, g_posFile
    g_positions := []
    Loop 10 {
        g_positions.Push({x: "", y: "", remark: ""})
    }
    if !FileExist(g_posFile) {
        return
    }
    try {
        local lineNum := 0
        Loop Read g_posFile
        {
            lineNum += 1
            if (lineNum > 10)
                break
            if (A_LoopReadLine = "")
                continue
            local parts := StrSplit(A_LoopReadLine, ",",, 4)
            if (parts.Length >= 3) {
                g_positions[lineNum].x := Trim(parts[2])
                g_positions[lineNum].y := Trim(parts[3])
                
                ; --- 【核心修正点】---
                ; 使用 parts.Length >= 4 来判断备注是否存在，而不是 IsSet()
                g_positions[lineNum].remark := (parts.Length >= 4) ? Trim(parts[4]) : ""
            }
        }
    } catch {
        MsgBox("读取位置文件 '" . g_posFile . "' 时发生错误。")
    }
}

SavePositions() {
    global g_positions, g_posFile
    local fileContent := ""
    Loop 10 {
        local index := A_Index
        local key := GetIndexAsKey(index)
        local pos := g_positions[index]
        fileContent .= key . "," . pos.x . "," . pos.y . "," . pos.remark . "`n"
    }
    try {
        local fileObj := FileOpen(g_posFile, "w", "UTF-8")
        fileObj.Write(Trim(fileContent, "`n"))
        fileObj.Close()
    } catch {
        MsgBox("写入位置文件 '" . g_posFile . "' 时发生错误。")
    }
}

RecordPosition(key) {
    global g_positions
    MouseGetPos(&x, &y)
    local index := GetKeyAsIndex(key)
    local pos := g_positions[index]

    if (pos.x != "") {
        local remarkText := ""
        if (Trim(pos.remark) != "") {
            remarkText := " (" . pos.remark . ")"
        }
        local message := "位置 '" . key . "'" . remarkText . " 已存在。是否要覆盖？"
        local response := MsgBox(message,, "YesNo")
        if (response = "No") {
            return
        }
    }
    
    g_positions[index] := {x: x, y: y, remark: pos.remark}
    SavePositions()
    
    ToolTip("位置 " . key . " 已保存: (" . x . ", " . y . ")")
    SetTimer(HideToolTip, -1500)
}

MoveToPosition(key) {
    global g_positions
    local index := GetKeyAsIndex(key)
    local pos := g_positions[index]
    if (pos.x != "") {
        MouseMove(pos.x, pos.y, 0)
    } else {
        ToolTip("位置 " . key . " 尚未记录。")
        SetTimer(HideToolTip, -1500)
    }
}

; =============================================
;          创建热键
; =============================================
; --- 移动鼠标 ---
0::MoveToPosition("0")
1::MoveToPosition("1")
2::MoveToPosition("2")
3::MoveToPosition("3")
4::MoveToPosition("4")
5::MoveToPosition("5")
6::MoveToPosition("6")
7::MoveToPosition("7")
8::MoveToPosition("8")
9::MoveToPosition("9")

; --- 记录坐标 ---
^0::RecordPosition("0")
^1::RecordPosition("1")
^2::RecordPosition("2")
^3::RecordPosition("3")
^4::RecordPosition("4")
^5::RecordPosition("5")
^6::RecordPosition("6")
^7::RecordPosition("7")
^8::RecordPosition("8")
^9::RecordPosition("9")


; =============================================
;          环绕视角
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