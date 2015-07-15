## README

The cheat sheet was created from `bug.n/doc/Default_hotkeys.md` as a source by 

* copying the file to `bug.n/doc/Cheat_sheet/`
* changing the title from "Default hotkeys" to "bug.n default hotkeys"
* removing the section "General description"
* finding and replacing `\r\n\r\n[^#*`&#96;`>].-\r\n\r\n` with `\r\n\r\n` (lpeg pattern)
-- This step has to be repeated. There are sections, which contain more than one additional paragraph.
* finding and replacing &#96;`Config_hotkey=` with `#### <kbd>`
* finding and replacing `::.-\n> ` with `</kbd>\n` (lpeg pattern)
* finding and replacing `<kbd>#` with `<kbd>Win</kbd><kbd>`
* finding and replacing `<kbd>!` with `<kbd>Alt</kbd><kbd>`
* finding and replacing `<kbd>^` with `<kbd>Ctrl</kbd><kbd>`
* finding and replacing `<kbd>+` with `<kbd>Shift</kbd><kbd>`
* finding and replacing `<n>` with `&lt;n&gt;`
* converting the markdown to HTML with the following command:
`pandoc -o cheat_sheet.html -S --section-divs -c reset.css -c cheat_sheet.css Default_hotkeys.md`

-- No, neither the resulting markdown, nor the HTML source is pretty. But with 
the accompanying CSS it looks good -- in Chromium browser at least.