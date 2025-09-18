#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force

; =============================================
;          引入功能模块
; =============================================
#Include Zoom.ahk
#include MousePos.ahk
#Include SmoothPan.ahk

; =============================================
;          全局设定
; =============================================
SendMode "Input"
CoordMode "Mouse", "Screen"

; =============================================
;          模块配置与实例化
; =============================================

global zoom_g := Zoom()
global mousePos_g := MousePos()
global smoothPan_g := SmoothPan({
    speed: 30,                       ; 全局速度控制器 (100 = 基础速度)
    minPixelMovePerFrame: 1.0,       ; 【关键参数】每帧最低移动像素
    baseOvershootDuration: 350,      ; 动画第一阶段（过冲）的基础时长（毫秒）
    baseSettleDuration: 450,         ; 动画第二阶段（缓动返回）的基础时长（毫秒）
    overshootFactor: 1.2,            ; 缓动回弹的幅度
    pauseDuration: 250,              ; 到达过冲点后的暂停时间
    frameDelay: 10                   ; 动画的“刷新率”
})


; #############################################
; ##          游戏内专属热键区域             ##
; #############################################
#HotIf WinActive("ahk_exe ck3.exe")
#MaxThreadsPerHotkey 2

; --- Zoom 模块热键 ---
NumpadMult::zoom_g.zoomIn()
NumpadDiv::zoom_g.zoomOut()
^NumpadMult::zoom_g.zoomIn(false)
^NumpadDiv::zoom_g.zoomOut(false)

; --- MousePos 模块热键 ---
0::mousePos_g.moveTo("0")
1::mousePos_g.moveTo("1")
2::mousePos_g.moveTo("2")
3::mousePos_g.moveTo("3")
4::mousePos_g.moveTo("4")
5::mousePos_g.moveTo("5")
6::mousePos_g.moveTo("6")
7::mousePos_g.moveTo("7")
8::mousePos_g.moveTo("8")
9::mousePos_g.moveTo("9")

^0::mousePos_g.record("0")
^1::mousePos_g.record("1")
^2::mousePos_g.record("2")
^3::mousePos_g.record("3")
^4::mousePos_g.record("4")
^5::mousePos_g.record("5")
^6::mousePos_g.record("6")
^7::mousePos_g.record("7")
^8::mousePos_g.record("8")
^9::mousePos_g.record("9")

; --- SmoothPan 模块热键 ---
Numpad5::smoothPan_g.toggle()

#HotIf ; 关闭上下文限制