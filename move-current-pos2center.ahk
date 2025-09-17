#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

global PI := 3.141592653589793
global isPanning := false

#HotIf WinActive("ahk_exe ck3.exe")

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

#HotIf

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