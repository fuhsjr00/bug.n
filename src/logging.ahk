/*
:title:     bug.n/logging
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Logging {
  /*
  Log messages from a source (e.g an Object.function) to a cache object depending on the current level w/ or w/o a timestamp.
  Logging.level:
    CRITICAL = 1
    ERROR    = 2
    WARNING  = 3
    INFO     = 4
    DEBUG    = 5
  */
  
  __New(labels := ";CRITICAL;ERROR;WARNING;INFO;DEBUG", level := 5, timeFormat := "yyyy-MM-dd HH:mm:ss") {
    this.labels := StrSplit(labels, ";")
    this.level := level
    this.timeFormat := timeFormat
    
    this.cache := []
    this.info("Started on level " . this.labels[this.level] . ".", "Logging.__New")
  }
  
  getTimestamp() {
    FormatTime, timestamp, , % this.timeFormat
    Return, timestamp
  }
  
  log(msg, src := "", level := 0, timestamp := True) {
    ;; src normally is the Object.function, where the log function was called from.
    ;; If level = 0, the message is logged independent from the current Logging.level.
    ;; If timestamp = False, the date and time is not added to the entry.
    ;; Instead of the level (integer), the label (text) is added to the entry.
    If (this.level >= level) {
      item := {}
      i := level + 1
      If (timestamp) {
        item.timestamp := this.getTimestamp()
      }
      item.level := this.labels[i]
      item.src := src
      item.msg := msg
      this.cache.push(item)
    }
  }
  ;; Explicit functions for the individual log levels, including timestamps.
  critical(msg, src) {
    this.log(msg, src, 1)
  }
  error(msg, src) {
    this.log(msg, src, 2)
  }
  warning(msg, src) {
    this.log(msg, src, 3)
  }
  info(msg, src) {
    this.log(msg, src, 4)
  }
  debug(msg, src) {
    this.log(msg, src, 5)
  }
  
  setLevel(delta, level := 0) {
    ;; If level = 0, delta should be -1 or +1 to de- or increment this.level.
    ;; The result should be between 1 and the maximum level (label index).
    level := level ? level : this.level
    level := Min(Max(level + delta, 1), this.labels.Length() - 1)
    If (level != this.level) {
      this.level := level
      i := level + 1
      this.log("Level set to " . this.labels[i] . ".", "Logging.setLevel")
    }
  }
}
