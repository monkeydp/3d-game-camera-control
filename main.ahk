#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force
#Include zoom.ahk

SendMode "Input"
CoordMode "Mouse", "Screen"
#HotIf WinActive("ahk_exe ck3.exe")

NumpadMult::Zoom.zoomIn()
NumpadDiv::Zoom.zoomOut()
^NumpadMult::Zoom.zoomIn(false)
^NumpadDiv::Zoom.zoomOut(false)