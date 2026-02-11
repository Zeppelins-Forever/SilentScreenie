# CaptureRegion.ps1 — Captures a screen region and copies it to the clipboard.
# Usage: powershell -NoProfile -STA -ExecutionPolicy Bypass -File CaptureRegion.ps1 <x> <y> <width> <height>
#
# Uses Win32 BitBlt instead of .NET CopyFromScreen to properly handle
# multi-monitor setups with negative coordinates and mixed DPI.
# Must be run with -STA flag for clipboard to work.

param(
    [int]$X,
    [int]$Y,
    [int]$W,
    [int]$H
)

Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class ScreenCapture {
    [DllImport("user32.dll")]
    static extern IntPtr GetDC(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);

    [DllImport("gdi32.dll")]
    static extern IntPtr CreateCompatibleDC(IntPtr hdc);

    [DllImport("gdi32.dll")]
    static extern IntPtr CreateCompatibleBitmap(IntPtr hdc, int nWidth, int nHeight);

    [DllImport("gdi32.dll")]
    static extern IntPtr SelectObject(IntPtr hdc, IntPtr hgdiobj);

    [DllImport("gdi32.dll")]
    static extern bool BitBlt(IntPtr hdcDest, int xDest, int yDest, int w, int h,
                              IntPtr hdcSrc, int xSrc, int ySrc, uint rop);

    [DllImport("gdi32.dll")]
    static extern bool DeleteObject(IntPtr hObject);

    [DllImport("gdi32.dll")]
    static extern bool DeleteDC(IntPtr hdc);

    [DllImport("user32.dll")]
    static extern bool SetProcessDPIAware();

    const uint SRCCOPY = 0x00CC0020;

    public static Bitmap Capture(int x, int y, int w, int h) {
        SetProcessDPIAware();

        // GetDC(IntPtr.Zero) returns the DC for the entire virtual screen
        // This correctly handles all monitors including negative coordinates
        IntPtr hdcScreen = GetDC(IntPtr.Zero);
        IntPtr hdcMem = CreateCompatibleDC(hdcScreen);
        IntPtr hBitmap = CreateCompatibleBitmap(hdcScreen, w, h);
        IntPtr hOld = SelectObject(hdcMem, hBitmap);

        BitBlt(hdcMem, 0, 0, w, h, hdcScreen, x, y, SRCCOPY);

        SelectObject(hdcMem, hOld);

        // Convert HBITMAP to .NET Bitmap (this copies the pixel data)
        Bitmap bmp = Image.FromHbitmap(hBitmap);

        DeleteObject(hBitmap);
        DeleteDC(hdcMem);
        ReleaseDC(IntPtr.Zero, hdcScreen);

        return bmp;
    }
}
"@ -ReferencedAssemblies System.Drawing

Add-Type -AssemblyName System.Windows.Forms

# Capture using Win32 API
$bmp = [ScreenCapture]::Capture($X, $Y, $W, $H)

# Copy to clipboard
[System.Windows.Forms.Clipboard]::SetImage($bmp)
$bmp.Dispose()
