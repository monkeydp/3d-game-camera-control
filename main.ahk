#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force
#Include zoom.ahk

SendMode "Input"
CoordMode "Mouse", "Screen"
#HotIf WinActive("ahk_exe ck3.exe")

global zoom_g :=  Zoom()
NumpadMult::zoom_g.zoomIn()
NumpadDiv::zoom_g.zoomOut()
^NumpadMult::zoom_g.zoomIn(false)
^NumpadDiv::zoom_g.zoomOut(false)