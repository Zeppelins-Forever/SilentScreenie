; ╔══════════════════════════════════════════════════════════════════════════════╗
; ║  InvisibleSnip — Drag-to-select screenshot → Clipboard                       ║
; ║  AutoHotkey v2 | Multi-monitor + mixed DPI support                           ║
; ║                                                                              ║
; ║  Place CaptureRegion.ps1 in the SAME folder as this script.                  ║
; ║                                                                              ║
; ║  Windows+Ctrl+Shift+A  — Drag-select a region, copies to clipboard           ║
; ║  Windows+Ctrl+Shift+Q  — Quit                                                ║
; ╚══════════════════════════════════════════════════════════════════════════════╝
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ─────────────────────────────────────────────────────────────────────────────
; DPI AWARENESS — Critical for multi-monitor with different scaling
; ─────────────────────────────────────────────────────────────────────────────
; This makes AHK report mouse coordinates in actual physical pixels,
; which will match what CopyFromScreen captures in the PS1 script.
; Without this, a 150%-scaled monitor would give coordinates that are
; 1.5x off from the real pixel positions.

; Try Per-Monitor V2 (best, Windows 10 1703+)
if !DllCall("SetProcessDpiAwarenessContext", "Ptr", -4, "Int") {
    ; Fall back to Per-Monitor V1 (Windows 8.1+)
    try DllCall("Shcore\SetProcessDpiAwareness", "Int", 2)
    catch
        DllCall("User32\SetProcessDPIAware")   ; basic fallback
}

; ─────────────────────────────────────────────────────────────────────────────
; HOTKEYS
; ─────────────────────────────────────────────────────────────────────────────

#^+a:: {
    ; --- Virtual screen bounds (spans ALL monitors) ---
    ; SysGet 76-79 gives the bounding rectangle of the entire virtual screen.
    ; On multi-monitor, this can have negative X/Y for monitors left of or
    ; above the primary monitor.
    sysX := SysGet(76)   ; SM_XVIRTUALSCREEN  (leftmost X)
    sysY := SysGet(77)   ; SM_YVIRTUALSCREEN  (topmost Y)
    sysW := SysGet(78)   ; SM_CXVIRTUALSCREEN (total width)
    sysH := SysGet(79)   ; SM_CYVIRTUALSCREEN (total height)

    ; --- Full-screen invisible overlay across ALL monitors ---
    overlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    overlay.BackColor := "000000"
    overlay.Show("x" sysX " y" sysY " w" sysW " h" sysH " NoActivate")
    WinSetTransparent(1, overlay)

    ; Thin red border to show selection
    selBox := Gui("+AlwaysOnTop -Caption +ToolWindow")
    selBox.BackColor := "FF0000"
    WinSetTransparent(1, selBox)

    ; Crosshair cursor
    hCross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "Ptr")
    DllCall("SetSystemCursor",
        "Ptr", DllCall("CopyImage", "Ptr", hCross, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr"),
        "UInt", 32512)

    ; Wait for left-click down
    KeyWait("LButton", "D")
    ; CoordMode ensures coordinates are relative to the entire virtual screen
    CoordMode("Mouse", "Screen")
    MouseGetPos(&startX, &startY)

    ; Track the drag
    loop {
        if !GetKeyState("LButton", "P")
            break
        MouseGetPos(&curX, &curY)
        rx := Min(startX, curX)
        ry := Min(startY, curY)
        rw := Abs(curX - startX)
        rh := Abs(curY - startY)
        if (rw > 2 && rh > 2) {
            selBox.Show("x" rx " y" ry " w" rw " h" rh " NoActivate")
            b := 2
            hOuter := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", rw, "Int", rh, "Ptr")
            hInner := DllCall("CreateRectRgn", "Int", b, "Int", b, "Int", rw - b, "Int", rh - b, "Ptr")
            DllCall("CombineRgn", "Ptr", hOuter, "Ptr", hOuter, "Ptr", hInner, "Int", 4)
            DllCall("DeleteObject", "Ptr", hInner)
            DllCall("SetWindowRgn", "Ptr", selBox.Hwnd, "Ptr", hOuter, "Int", 1)
        }
        Sleep(10)
    }
    MouseGetPos(&endX, &endY)

    ; Restore default cursor
    DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)

    ; Destroy overlays BEFORE capture
    selBox.Destroy()
    overlay.Destroy()
    Sleep(300)

    ; Calculate region (handles any drag direction)
    x1 := Min(startX, endX)
    y1 := Min(startY, endY)
    w  := Abs(endX - startX)
    h  := Abs(endY - startY)

    if (w < 5 || h < 5) {
        ToolTip("Selection too small")
        SetTimer(() => ToolTip(), -1000)
        return
    }

    ; --- Call PowerShell to capture and copy to clipboard ---
    psScript := A_ScriptDir "\CaptureRegion.ps1"
    if !FileExist(psScript) {
        MsgBox("CaptureRegion.ps1 not found!`n`nPlace it in the same folder as this script:`n" A_ScriptDir)
        return
    }

    ; Pass raw virtual screen coordinates — these can be negative
    ; for monitors to the left of/above the primary monitor
    cmd := "powershell -NoProfile -STA -ExecutionPolicy Bypass -File "
    cmd .= "`"" psScript "`" "
    cmd .= " -X " x1 " -Y " y1 " -W " w " -H " h
    ; Old method:  cmd .= x1 " " y1 " " w " " h  --  caused issues with PowerShell
    ; program reading argument values as command line flags.

    RunWait(cmd, , "Hide")

    ToolTip("Copied!")
    SetTimer(() => ToolTip(), -800)
}

#^+q::ExitApp
