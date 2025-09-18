#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"
CoordMode "Mouse", "Screen"

; #####################################################################
; ##                                                                 ##
; ##               最终的、绝对可靠的 SmoothPan 类                   ##
; ##                                                                 ##
; #####################################################################

class SmoothPan
{
    ; --- 类的属性 (源自您的全局变量，已恢复注释) ---
    _speed := 100                  ; 移动速度 (100 = 基础速度)
    _minPixelMovePerFrame := 1.0   ; 每帧最低移动像素
    _baseOvershootDuration := 350  ; 过冲阶段的基础时长
    _baseSettleDuration := 450     ; 稳定阶段的基础时长
    _overshootFactor := 1.3        ; 回弹幅度
    _pauseDuration := 250          ; 过冲后的暂停时间
    _frameDelay := 10              ; 动画的刷新率
    _PI := 3.141592653589793       ; PI 常量
    _isPanning := false            ; 内部状态：是否正在平移
    
    ; --- 构造函数 (使用了绝对正确的 .HasOwnProp 方法) ---
    __New(config := 0)
    {
        if (IsObject(config))
        {
            if (config.HasOwnProp("speed"))
                this._speed := config.speed
            if (config.HasOwnProp("minPixelMovePerFrame"))
                this._minPixelMovePerFrame := config.minPixelMovePerFrame
            if (config.HasOwnProp("baseOvershootDuration"))
                this._baseOvershootDuration := config.baseOvershootDuration
            if (config.HasOwnProp("baseSettleDuration"))
                this._baseSettleDuration := config.baseSettleDuration
            if (config.HasOwnProp("overshootFactor"))
                this._overshootFactor := config.overshootFactor
            if (config.HasOwnProp("pauseDuration"))
                this._pauseDuration := config.pauseDuration
            if (config.HasOwnProp("frameDelay"))
                this._frameDelay := config.frameDelay
        }
    }

    ; --- 公共方法 ---
    toggle()
    {
        if (this._isPanning) {
            this._isPanning := false
            return
        }
        this._isPanning := true
        this._executePanToCenter()
        this._isPanning := false
    }
    
    ; --- 私有方法 ---
    _easeInOut(p) => -(Cos(this._PI * p) - 1) / 2
    _easeOutQuad(p) => p * (2 - p)

    _executePanToCenter() {
        if (this._speed <= 0) {
            this._speed := 1
        }

        local targetOvershootDuration := this._baseOvershootDuration / (this._speed / 100)
        local targetSettleDuration := this._baseSettleDuration / (this._speed / 100)
        
        MouseGetPos(&startX, &startY)
        local centerX := A_ScreenWidth // 2, centerY := A_ScreenHeight // 2
        local totalMoveX := centerX - startX, totalMoveY := centerY - startY
        
        local overshootMouseX := startX + totalMoveX * this._overshootFactor
        local overshootMouseY := startY + totalMoveY * this._overshootFactor
        local finalMouseX := startX + totalMoveX, finalMouseY := startY + totalMoveY
        
        SendInput("{MButton Down}")
        Sleep(20)

        local floatX := startX, floatY := startY
        local lastEasedProgress := 0
        local startTime := A_TickCount
        
        while ((A_TickCount - startTime < targetOvershootDuration) and (Sqrt((overshootMouseX - floatX)**2 + (overshootMouseY - floatY)**2) > 0.5))
        {
            if (!this._isPanning)
            {
                SendInput("{MButton Up}")
                return
            }
            
            local progress := (A_TickCount - startTime) / targetOvershootDuration
            local easedProgress := this._easeInOut(progress)
            local deltaProgress := easedProgress - lastEasedProgress
            local deltaX := (overshootMouseX - startX) * deltaProgress
            local deltaY := (overshootMouseY - startY) * deltaProgress
            
            local distance := Sqrt(deltaX**2 + deltaY**2)
            if (distance > 0 and distance < this._minPixelMovePerFrame)
            {
                local scale := this._minPixelMovePerFrame / distance
                deltaX *= scale, deltaY *= scale
                local remainingX := overshootMouseX - floatX, remainingY := overshootMouseY - floatY
                local remainingDist := Sqrt(remainingX**2 + remainingY**2)
                if (Sqrt(deltaX**2 + deltaY**2) > remainingDist)
                {
                    deltaX := remainingX, deltaY := remainingY
                }
            }

            floatX += deltaX, floatY += deltaY
            MouseMove(Round(floatX), Round(floatY), 0)
            lastEasedProgress := easedProgress
            Sleep(this._frameDelay)
        }
        MouseMove(Round(overshootMouseX), Round(overshootMouseY), 0)

        Sleep(this._pauseDuration)

        if (!this._isPanning)
        {
            SendInput("{MButton Up}")
            return
        }

        floatX := overshootMouseX, floatY := overshootMouseY
        lastEasedProgress := 0
        startTime := A_TickCount
        
        while ((A_TickCount - startTime < targetSettleDuration) and (Sqrt((finalMouseX - floatX)**2 + (finalMouseY - floatY)**2) > 0.5))
        {
            if (!this._isPanning)
            {
                SendInput("{MButton Up}")
                return
            }

            local progress := (A_TickCount - startTime) / targetSettleDuration
            local easedProgress := this._easeOutQuad(progress)
            local deltaProgress := easedProgress - lastEasedProgress
            local deltaX := (finalMouseX - overshootMouseX) * deltaProgress
            local deltaY := (finalMouseY - overshootMouseY) * deltaProgress

            local distance := Sqrt(deltaX**2 + deltaY**2)
            if (distance > 0 and distance < this._minPixelMovePerFrame)
            {
                local scale := this._minPixelMovePerFrame / distance
                deltaX *= scale, deltaY *= scale
                local remainingX := finalMouseX - floatX, remainingY := finalMouseY - floatY
                local remainingDist := Sqrt(remainingX**2 + remainingY**2)
                if (Sqrt(deltaX**2 + deltaY**2) > remainingDist)
                {
                    deltaX := remainingX, deltaY := remainingY
                }
            }

            floatX += deltaX, floatY += deltaY
            MouseMove(Round(floatX), Round(floatY), 0)
            lastEasedProgress := easedProgress
            Sleep(this._frameDelay)
        }
        MouseMove(Round(finalMouseX), Round(finalMouseY), 0)

        SendInput("{MButton Up}")
    }
}