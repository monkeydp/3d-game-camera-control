#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force

; ====================================================================
;                        1. 全局设定与模块引入
; ====================================================================

#Include Zoom.ahk
#include MousePos.ahk
#Include SmoothPan.ahk
#Include AHIRemapper.ahk
#Include AutoOrbit.ahk

SendMode "Input"
CoordMode "Mouse", "Screen"

global wintitle := "ahk_exe ck3.exe"

; ====================================================================
;                  2. AHIRemapper 模块 (背景服务)
; ====================================================================

{
    ; --- 在局部代码块中定义常量,避免污染全局 ---
    UP := 328, RIGHT := 333, LEFT := 331, DOWN := 336
    NUM_1 := 79, NUM_2 := 80, NUM_3 := 81, NUM_4 := 75
    NUM_6 := 77, NUM_7 := 71, NUM_8 := 72, NUM_9 := 73

    ; --- 构建映射表 ---
    mappings := Map(
        NUM_1, [LEFT, DOWN],
        NUM_3, [RIGHT, DOWN],
        NUM_7, [LEFT, UP],
        NUM_9, [RIGHT, UP],
        NUM_8, [UP],
        NUM_2, [DOWN],
        NUM_4, [LEFT],
        NUM_6, [RIGHT]
    )

    global ahir_g := AHIRemapper({
        keyboardId: 1,
        keyMappings: mappings,
        winTitle: wintitle
    })
}

ahir_g.start()


; ====================================================================
;                3. 游戏内专属模块与热键 (ck3.exe)
; ====================================================================
#HotIf WinActive(wintitle)
#MaxThreadsPerHotkey 2

; --------------------------------------------------------------------
; --- SmoothPan 模块 ---
; --------------------------------------------------------------------

global smoothPan_g := SmoothPan({
    speed: 30,                       ; 移动速度 (100 = 基础速度)
    minPixelMovePerFrame: 1.0,       ; 每帧最低移动像素
    baseOvershootDuration: 350,      ; 过冲阶段的基础时长（毫秒）
    baseSettleDuration: 450,         ; 缓动返回的基础时长（毫秒）
    overshootFactor: 1.2,            ; 缓动回弹的幅度
    pauseDuration: 250,              ; 到达过冲点后的暂停时间
    frameDelay: 10                   ; 动画的“刷新率”
})

Numpad5:: smoothPan_g.toggle()


; --------------------------------------------------------------------
; --- MousePos 模块 ---
; --------------------------------------------------------------------

global mousePos_g := MousePos()

0:: mousePos_g.moveTo("0")
1:: mousePos_g.moveTo("1")
2:: mousePos_g.moveTo("2")
3:: mousePos_g.moveTo("3")
4:: mousePos_g.moveTo("4")
5:: mousePos_g.moveTo("5")
6:: mousePos_g.moveTo("6")
7:: mousePos_g.moveTo("7")
8:: mousePos_g.moveTo("8")
9:: mousePos_g.moveTo("9")

^0:: mousePos_g.record("0")
^1:: mousePos_g.record("1")
^2:: mousePos_g.record("2")
^3:: mousePos_g.record("3")
^4:: mousePos_g.record("4")
^5:: mousePos_g.record("5")
^6:: mousePos_g.record("6")
^7:: mousePos_g.record("7")
^8:: mousePos_g.record("8")
^9:: mousePos_g.record("9")


; --------------------------------------------------------------------
; --- Zoom 模块 ---
; --------------------------------------------------------------------

global zoom_g := Zoom({
    uniformDuration: 5000,     ; 匀速缩放的总时长 (毫秒)。
    uniformInterval: 50,       ; 匀速滚动的固定时间间隔 (毫秒),决定了匀速模式的速度。
    smoothDuration: 2000,      ; 平滑缩放的总时长 (毫秒)。
    minSmoothInterval: 50,     ; 平滑缩放的最小时间间隔 (毫秒),决定了结束时的最快速度。
    maxSmoothInterval: 150     ; 平滑缩放的最大时间间隔 (毫秒),决定了开始时的最慢速度。
})

NumpadMult:: zoom_g.zoomIn()
NumpadDiv:: zoom_g.zoomOut()
^NumpadMult:: zoom_g.zoomIn(false)
^NumpadDiv:: zoom_g.zoomOut(false)


; --------------------------------------------------------------------
; --- AutoOrbit 模块 ---
; --------------------------------------------------------------------

global orbit_g := AutoOrbit({
    step_x: -2,                  ; 每次向【右】移动的像素距离。
    step_y: 0,                  ; 每次向【下】移动的像素距离。
    step_delay: 20,             ; 每次移动的延迟时间(毫秒)。
    edge_margin: [100],         ; 屏幕边缘安全距离。
    duration: 25.5,             ; 主动环绕时长（秒）。
    release_delay_on_edge: 1,   ; 到达边缘或达到主动时长后,延迟多久松开右键（秒）。
    timeout: 60                 ; 安全保险,防止脚本意外失控。
})

NumpadAdd:: orbit_g.toggle()

~RButton::
{
    if (orbit_g._isOrbiting)
        orbit_g.stop()
}

^NumpadAdd::
{
    orbit_g.stop()
    Sleep(50)
    Reload()
}

; ====================================================================
;                4. 初始化
; ====================================================================

NumpadSub:: {
    zoom_g.zoomOut(false)
    mousePos_g.moveTo("1")
    Send("^{F9}")
}

#HotIf ; 关闭上下文限制
