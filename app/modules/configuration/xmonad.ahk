/*
:title:     bug.n/configuration/xmonad
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class Configuration {
  __New() {
    Global logger
    
    this.name := "xmonad"
    
    logger.info("<b>" . this.name . "</b> configuration loaded.", "Configuration.__New")
  }
}
