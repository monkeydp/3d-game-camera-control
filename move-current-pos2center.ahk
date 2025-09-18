#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

; --- 【可配置参数】 ---

; 全局速度控制器 (100 = 基础速度)
global globalSpeed := 10

; 【关键参数：每帧最低移动像素】
global minPixelMovePerFrame := 1.0

; 动画第一阶段（过冲）的基础时长（毫秒）
global baseOvershootDuration := 350

; 动画第二阶段（缓动返回）的基础时长（毫roic）
global baseSettleDuration := 450

; 缓动回弹的幅度
global overshootFactor := 1.3

; 到达过冲点后的暂停时间
global pauseDuration := 250

; 动画的“刷新率”
global frameDelay := 10

; --- 全局状态变量 ---
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

EaseInOut(p) => -(Cos(PI * p) - 1) / 2
EaseOutQuad(p) => p * (2 - p)

SmoothPanToCenter() {
    global isPanning, globalSpeed, baseOvershootDuration, baseSettleDuration
    global overshootFactor, pauseDuration, frameDelay, minPixelMovePerFrame

    if (globalSpeed <= 0) {
        globalSpeed := 1
    }

    targetOvershootDuration := baseOvershootDuration / (globalSpeed / 100)
    targetSettleDuration := baseSettleDuration / (globalSpeed / 100)
    
    MouseGetPos(&startX, &startY)
    centerX := A_ScreenWidth // 2, centerY := A_ScreenHeight // 2
    totalMoveX := centerX - startX, totalMoveY := centerY - startY
    
    overshootMouseX := startX + totalMoveX * overshootFactor
    overshootMouseY := startY + totalMoveY * overshootFactor
    finalMouseX := startX + totalMoveX, finalMouseY := startY + totalMoveY
    
    Send("{MButton Down}")
    Sleep(20)

    floatX := startX, floatY := startY
    lastEasedProgress := 0
    startTime := A_TickCount
    
    while ((A_TickCount - startTime < targetOvershootDuration) and (Sqrt((overshootMouseX - floatX)**2 + (overshootMouseY - floatY)**2) > 0.5))
    {
        if (!isPanning)
        {
            Send("{MButton Up}")
            return
        }
        
        progress := (A_TickCount - startTime) / targetOvershootDuration
        easedProgress := EaseInOut(progress)
        deltaProgress := easedProgress - lastEasedProgress

        deltaX := (overshootMouseX - startX) * deltaProgress
        deltaY := (overshootMouseY - startY) * deltaProgress
        
        distance := Sqrt(deltaX**2 + deltaY**2)
        if (distance > 0 and distance < minPixelMovePerFrame)
        {
            scale := minPixelMovePerFrame / distance
            deltaX *= scale, deltaY *= scale
            remainingX := overshootMouseX - floatX, remainingY := overshootMouseY - floatY
            remainingDist := Sqrt(remainingX**2 + remainingY**2)
            if (Sqrt(deltaX**2 + deltaY**2) > remainingDist) {
                deltaX := remainingX, deltaY := remainingY
            }
        }

        floatX += deltaX, floatY += deltaY
        MouseMove(Round(floatX), Round(floatY), 0)
        lastEasedProgress := easedProgress
        Sleep(frameDelay)
    }
    MouseMove(Round(overshootMouseX), Round(overshootMouseY), 0)

    Sleep(pauseDuration)

    if (!isPanning)
    {
        Send("{MButton Up}")
        return
    }

    floatX := overshootMouseX, floatY := overshootMouseY
    lastEasedProgress := 0
    startTime := A_TickCount
    
    while ((A_TickCount - startTime < targetSettleDuration) and (Sqrt((finalMouseX - floatX)**2 + (finalMouseY - floatY)**2) > 0.5))
    {
        if (!isPanning)
        {
            Send("{MButton Up}")
            return
        }

        progress := (A_TickCount - startTime) / targetSettleDuration
        easedProgress := EaseOutQuad(progress)
        deltaProgress := easedProgress - lastEasedProgress

        deltaX := (finalMouseX - overshootMouseX) * deltaProgress
        deltaY := (finalMouseY - overshootMouseY) * deltaProgress

        distance := Sqrt(deltaX**2 + deltaY**2)
        if (distance > 0 and distance < minPixelMovePerFrame)
        {
            scale := minPixelMovePerFrame / distance
            deltaX *= scale, deltaY *= scale
            remainingX := finalMouseX - floatX, remainingY := finalMouseY - floatY
            remainingDist := Sqrt(remainingX**2 + remainingY**2)
            if (Sqrt(deltaX**2 + deltaY**2) > remainingDist) {
                deltaX := remainingX, deltaY := remainingY
            }
        }

        floatX += deltaX, floatY += deltaY
        MouseMove(Round(floatX), Round(floatY), 0)
        lastEasedProgress := easedProgress
        Sleep(frameDelay)
    }
    MouseMove(Round(finalMouseX), Round(finalMouseY), 0)

    Send("{MButton Up}")
}