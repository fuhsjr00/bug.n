## README

The cheat sheet was created from `bug.n/doc/Default_hotkeys.md` as a source by 

* copying the file to `bug.n/doc/Cheat_sheet/`
* changing the title from "Default hotkeys" to "bug.n default hotkeys"
* changing the heading "General description" to "Abbreviations"
* finding and replacing "\r\n\r\n[^#*`>].-\r\n\r\n" with "\r\n\r\n" (lpeg pattern)
* finding and replacing "`Config_hotkey=" with "#### " (lpeg pattern)
* finding and replacing "::.-\n> " with "\n" (lpeg pattern)
* converting the markdown to HTML with the following command:
`pandoc -o cheat_sheet.html -S --section-divs -c reset.css -c cheat_sheet.css Default_hotkeys.md`

-- No, neither the resulting markdown, nor the HTML source is pretty. But with 
the accompanying CSS it looks good.