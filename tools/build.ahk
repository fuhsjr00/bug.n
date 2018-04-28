/*
:title:     bug.n -- tiling window management
:copyright: (c) 2010-2017 by Joshua Fuhs, joten <https://github.com/joten>
:license:   GNU General Public License version 3; for more details: 
            ../LICENSE.md or at <http://www.gnu.org/licenses/>.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

;; script settings
#NoEnv                        ;; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input                ;; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines, -1
SetControlDelay, 0
SetTitleMatchMode, 3
SetTitleMatchMode, Fast
SetWorkingDir %A_ScriptDir%   ;; Ensures a consistent starting directory.
#SingleInstance Force
;#Warn                         ;; Enable warnings to assist with detecting common errors.

;; pseudo main function
  M_NAME     := "bug.n"
  M_VERSION  := "9.0.2-a"
  Progress,,,, Building %M_NAME%
  M_logLevel := 5             ;; higher values mean more logging, type = int, choices = [0, 1, 2, 3, 4, 5, 6], default = 5
  
  _log := new Logging(A_ScriptDir . "\log-build-" . A_ComputerName . "_" . A_UserName . ".md",, M_logLevel)
  _log.message("Building " . M_NAME . " started", 4)
  Progress, 10
  
  compile(A_ScriptDir . "\..\src\Main.ahk", A_ScriptDir . "\..\bugn.exe", A_ScriptDir . "\..\src\logo.ico")
  Progress, 70
  
  createCheatSheet(A_ScriptDir . "\..\doc\Default_hotkeys.md", A_ScriptDir . "\..\doc\Cheat_sheet")
  Progress, 100
  
  _log.message("Building " . M_NAME . " finished", 0)
  Sleep, 500
  Progress, OFF
Return
;; end of the auto-execute section

;; class, function & label definitions
class Logging {
  __New(file, truncate := True, level := 0) {
    this.file  := file
    this.level := level ? level : 6
    this.label := StrSplit(";CRITICAL;ERROR;WARNING;INFO;DEBUG;SUPER", ";")
    
    If (truncate && FileExist(this.file)) {
      FileDelete, % this.file
      this.message("**Logging.__New**: File deleted (``" . this.file . "``)", 3)
    }
    FormatTime, timestamp, , yyyy-MM-dd
    FileAppend, % "`r`n# " . timestamp . "`r`n", % this.file
    this.message("Logging started with log level " . this.level, 4)
  }
  
  message(text, level, timestamp := True) {    ;; level = 0: log in any case
    If (this.level >= level) {
      If timestamp
        FormatTime, timestamp, , yyyy-MM-dd HH:mm:ss
      i := level + 1
      text := StrPad(timestamp, " ", 19) . "> " . StrPad(this.label[i], ".", 8) . ": " . text . "`r`n"
      FileAppend, % text, % this.file
    }
  }
  
  setLevel(d, level := 0) {
    level := level ? level : this.level
    level := IntMin(IntMax(level + d, 1), 6)
    If (level != this.level) {
      this.level := level
      i := level + 1
      this.message("Log level set to " . this.label[i], 0)
    }
  }
}

compile(source, destination, customIcon, compiler := "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe", compressor := "C:\Program Files\AutoHotkey\Compiler\mpress.exe") {
  Global _log
  
  useMpress := FileExist(compressor) ? "1" : "0"
  _log.message("**compile**: Variable set, source      -> ``" . source      . "``, the file does " . (FileExist(source)      ? "" : "**not** ") . "exist.", 5)
  _log.message("**compile**: Variable set, destination -> ``" . destination . "``, the file does " . (FileExist(destination) ? "" : "**not** ") . "exist.", 5)
  _log.message("**compile**: Variable set, customIcon  -> ``" . customIcon  . "``, the file does " . (FileExist(customIcon)  ? "" : "**not** ") . "exist.", 5)
  _log.message("**compile**: Variable set, compiler    -> ``" . compiler    . "``, the file does " . (FileExist(compiler)    ? "" : "**not** ") . "exist.", 5)
  _log.message("**compile**: Variable set, useMpress   -> ``" . useMpress   . "``", 5)
  If (FileExist(source) && FileExist(compiler))
    RunWait, %compiler% /in %source% /icon %customIcon% /mpress %useMpress% /out %destination%
  _log.message("Compiling the script to an executable finished.", 4)
}

createCheatSheet(source, destDir, filename := "cheat_sheet", converter := "C:\Users\joten\AppData\Local\Pandoc\pandoc.exe") {
  Global _log, M_NAME, M_VERSION
  
  _log.message("**createCheatSheet**: Variable set, source    -> ``" . source    . "``, the file does " . (FileExist(source)    ? "" : "**not** ") . "exist.", 5)
  _log.message("**createCheatSheet**: Variable set, destDir   -> ``" . destDir   . "``, the file does " . (FileExist(destDir)   ? "" : "**not** ") . "exist.", 5)
  _log.message("**createCheatSheet**: Variable set, converter -> ``" . converter . "``, the file does " . (FileExist(converter) ? "" : "**not** ") . "exist.", 5)
  If (FileExist(source) && FileExist(destDir) && FileExist(converter)) {
    FileRead, md, %source%
    If (ErrorLevel = 0) {
      md := RegExReplace(md, "s)^## Default hotkeys\R\R.+\R\### Window management", "## " . M_NAME . " " . M_VERSION . " default hotkeys`r`n`r`n### Window management")
      md := StrReplace(md, "`r`n-------------------------------------------------------------------------------`r`n", "`r`n")
      md := RegExReplace(md, "s)\R>.+?\R\R", "`r`n")
      md := RegExReplace(md, "s)\R>.+?\R\R", "`r`n")
      md := StrReplace(md, "``Config_hotkey=", "#### <kbd>")
      md := RegExReplace(md, "::.+\R", "</kbd>")
      md := StrReplace(md, "<kbd>#", "<kbd>Win</kbd><kbd>")
      md := StrReplace(md, "<kbd>!", "<kbd>Alt</kbd><kbd>")
      md := StrReplace(md, "<kbd>^", "<kbd>Ctrl</kbd><kbd>")
      md := StrReplace(md, "<kbd>+", "<kbd>Shift</kbd><kbd>")
      md := StrReplace(md, "<n>", "&lt;n&gt;")
      FileDelete, %destDir%\%filename%.md
      FileAppend, %md%, %destDir%\%filename%.md
    }
    RunWait, % converter . " -o " . destDir . "\" . filename . ".html -S --section-divs -c reset.css -c cheat_sheet.css " . destDir . "\" . filename . ".md"
  }
  _log.message("Creating the cheat sheet finished.", 4)
}

IntMin(int_1, int_2) {
  Return, int_1 < int_2 ? int_1 : int_2
}

IntMax(int_1, int_2) {
  Return, int_1 > int_2 ? int_1 : int_2
}

StrPad(s, chars, count) {
  str := ""
  Loop, % Abs(count)
    str .= chars
  If (count < 0)
    Return SubStr(str . s, count + 1)
  Else
    Return SubStr(s . str, 1, count)
}
