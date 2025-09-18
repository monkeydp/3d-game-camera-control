#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

; --- 【可配置参数】 ---
; --- 您可以在这里自由调整，以改变动画的手感 ---

; 全局速度控制器 (100 = 基础速度)
global globalSpeed := 10

; 动画第一阶段（过冲）的基础时长（毫秒）
global baseOvershootDuration := 350

; 动画第二阶段（缓动返回）的基础时长（毫秒）
global baseSettleDuration := 450

; 缓动回弹的幅度（1.0 = 不回弹, 1.3 = 回弹30%）
global overshootFactor := 1.3

; 到达过冲点后的暂停时间（毫秒）
global pauseDuration := 250

; 动画的“刷新率”，即每帧之间的延时（毫秒）。建议保持在 10-16 之间。
global frameDelay := 10

; --- 【全局状态变量】 ---
global PI := 3.141592653589793
global isPanning := false


#HotIf WinActive("ahk_exe ck3.exe")
#MaxThreadsPerHotkey 2

Numpad5::
{
    global isPanning
    if (isPanning) {
        isPanning := false
        return
    }
    isPanning := true
    SmoothPanToCenter()
    isPanning := false
}
#HotIf

; 使用更简洁的胖箭头函数语法
EaseInOut(p) => -(Cos(PI * p) - 1) / 2
EaseOutCubic(p) => 1 - (1 - p) ** 3

SmoothPanToCenter() {
    ; --- 引用所有全局参数 ---
    global isPanning, globalSpeed, baseOvershootDuration, baseSettleDuration
    global overshootFactor, pauseDuration, frameDelay

    if (globalSpeed <= 0) {
        globalSpeed := 1
    }

    ; 根据 globalSpeed 计算实际的动画持续时间
    targetOvershootDuration := baseOvershootDuration / (globalSpeed / 100)
    targetSettleDuration := baseSettleDuration / (globalSpeed / 100)
    
    MouseGetPos(&startX, &startY)
    centerX := A_ScreenWidth // 2, centerY := A_ScreenHeight // 2
    totalMoveX := centerX - startX, totalMoveY := centerY - startY
    
    ; 注意：这里的计算目标点位也应该是浮点数，以保持最高精度
    overshootMouseX := startX + totalMoveX * overshootFactor
    overshootMouseY := startY + totalMoveY * overshootFactor
    finalMouseX := startX + totalMoveX, finalMouseY := startY + totalMoveY
    
    Send("{MButton Down}")
    Sleep(20)

    ; --- 【核心修正】第一阶段：过冲动画 (使用增量累加) ---
    floatX := startX, floatY := startY  ; 初始化理想浮点坐标
    lastEasedProgress := 0              ; 初始化上一帧的进度
    startTime := A_TickCount
    while ((elapsedTime := A_TickCount - startTime) < targetOvershootDuration) {
        if (!isPanning) {
            Send("{MButton Up}")
            return
        }
        
        progress := elapsedTime / targetOvershootDuration
        easedProgress := EaseInOut(progress)
        deltaProgress := easedProgress - lastEasedProgress ; 计算自上一帧以来的进度增量

        ; 将增量带来的位移，累加到理想浮点坐标上
        floatX += (overshootMouseX - startX) * deltaProgress
        floatY += (overshootMouseY - startY) * deltaProgress

        MouseMove(Round(floatX), Round(floatY), 0) ; 移动到圆整后的理想坐标
        lastEasedProgress := easedProgress ; 更新上一帧进度以备下次计算
        Sleep(frameDelay)
    }
    MouseMove(Round(overshootMouseX), Round(overshootMouseY), 0) ; 循环结束后，确保精确到达过冲点

    Sleep(pauseDuration)
    if (!isPanning) {
        Send("{MButton Up}")
        return
    }

    ; --- 【核心修正】第二阶段：稳定动画 (使用增量累加) ---
    floatX := overshootMouseX, floatY := overshootMouseY ; 重置理想坐标为当前的过冲点
    lastEasedProgress := 0
    startTime := A_TickCount
    while ((elapsedTime := A_TickCount - startTime) < targetSettleDuration) {
        if (!isPanning) {
            Send("{MButton Up}")
            return
        }

        progress := elapsedTime / targetSettleDuration
        easedProgress := EaseOutCubic(progress)
        deltaProgress := easedProgress - lastEasedProgress

        floatX += (finalMouseX - overshootMouseX) * deltaProgress
        floatY += (finalMouseY - overshootMouseY) * deltaProgress

        MouseMove(Round(floatX), Round(floatY), 0)
        lastEasedProgress := easedProgress
        Sleep(frameDelay)
    }
    MouseMove(Round(finalMouseX), Round(finalMouseY), 0) ; 循环结束后，确保精确到达最终中心点

    Send("{MButton Up}")
}