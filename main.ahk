#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force

; =============================================
;          引入功能模块
; =============================================
#Include zoom.ahk
#include mouse-pos.ahk

; =============================================
;          全局设定
; =============================================
SendMode "Input"
CoordMode "Mouse", "Screen"

; =============================================
;          模块实例化
; =============================================
global zoom_g := Zoom()
global mousePos_g := MousePos()

; #############################################
; ##          游戏内专属热键区域             ##
; #############################################
#HotIf WinActive("ahk_exe ck3.exe")

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

#HotIf ; 关闭上下文限制