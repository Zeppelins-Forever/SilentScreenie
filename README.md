# SilentScreenie
A multi-monitor screenshot tool for Windows that doesn't darken the screen.

This is built on top of AutoHotKey 2.0.

### Why use this?

- Windows's built-in Snipping Tool, while versatile and useful for OCR, cannot take screenshots spanning across multiple monitors, whereas SilentScreenie can!
- Snipping Tool significantly darkens Windows's screen whenever you're taking a screenshot. This one doesn't! While it's a little less clear precisely what you're selecting, it's simply a tradeoff. Many times in the past I couldn't see exactly what I wanted to screenshot due to the dark filter on the Windows screen.

### How to use this
There are two different ways to use this:

1. Without installing AutoHotKeys
   1. Go to the Releases page and download the latest ZIP file that says "no-AHK". Make sure you choose "x64" if you're on a relatively modern, non-ARM-based computer.
   2. Extract the ZIP file anywhere.
   3. Go into the ZIP and run `SilentScreenie.exe`. This will launch the app in the taskbar! Do not remove `CaptureRegion.ps1`, this needs to be in the same directory as `SilentScreenie.exe` to function.
   4. If you encounter an error, you have two options:
      1. Create your own PS1 file with the same name, copy-paste the code from `CaptureRegion.ps1` into it, and replace the original file with your version. Windows should recognize the file as yours, and thus allowed to run. Or,
      2. Run `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`. This allows all PowerShell scripts to run on your local machine without issue, but is less secure.
   5. Press `Windows`+`Ctrl`+`Shift`+`A` to take a screenshot. Press `Windows`+`Ctrl`+`Shift`+`Q` to quit the app.
   6. You're done!
2. With AutoHotKey installed
   1. Make sure you have [AutoHotKey](https://www.autohotkey.com/) installed on your system, specifically version 2.0 or above! It should have all the required file associations on your system, such as `.ahk`.
   2. Go to the Releases page and download the latest ZIP file that says "AHK-required". Make sure you choose "x64" if you're on a relatively modern, non-ARM-based computer.
   3. Extract the ZIP file anywhere.
   4. Go into the ZIP and run `SilentScreenie.ahk`. This will launch the app in the taskbar! Do not remove `CaptureRegion.ps1`, this needs to be in the same directory as `SilentScreenie.exe` to function.
   5. If you encounter an error, you have two options:
      1. Create your own PS1 file with the same name, copy-paste the code from `CaptureRegion.ps1` into it, and replace the original file with your version. Windows should recognize the file as yours, and thus allowed to run. Or,
      2. Run `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`. This allows all PowerShell scripts to run on your local machine without issue, but is less secure.
   6. Press `Windows`+`Ctrl`+`Shift`+`A` to take a screenshot. Press `Windows`+`Ctrl`+`Shift`+`Q` to quit the app.
   7. You're done!
