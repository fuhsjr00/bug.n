# bug.n App Calls

* possible value: an array of rules represented by objects with the keys `conditions` and `actions`. Their values are arrays of strings representing an app call as described below, e.g. `get/windows/_?<property=value>` as a condition checking if a window's property matches a value or `set/windows?id=_&tile=True` as an action letting bug.n manage and tile the window.
* Defined conditions are concatenated with a logical and, therefor all conditions have to be met, if any defined action should be taken.
* The first rule may be seen as a default filter, the last rule (in general meeting the inverse conditions of the default filter) as defining the default actions. Any additional (more specific) rules should go in between.
* If a rule meets all conditions and has not the action `break` set, the following rule(s) are processed and the resulting actions are superposed.

| Class         | Instance  | App Call Path  |
| ------------- | --------- | -------------- |
| Configuration | config    | configuration  |
| Logging       | logger    | log            |
| Desktop       | desktops  | desktops       |
| Monitor       | monitors  | monitors       |
| WorkArea      | workareas | workareas      |
| UserInterface | uifaces   | userinterfaces |
| View          | views     | views          |
| Window        | windows   | windows        |

| Window Property | Value                      |
| --------------- | -------------------------- |
| id              | 6-digit hexadecimal number |
| class           | RegEx string               |
| title           | RegEx string               |
| pName           | RegEx string               |
| pPath           | RegEx string               |
| style           | 8-digit hexadecimal number |
| exStyle         | 8-digit hexadecimal number |
| minMax          | -1, 0, 1                   |
| isAppWindow     | True, False                |
| isChild         | True, False                |
| isElevated      | True, False                |
| isPopup         | True, False                |

Example app call for use in conditions: get/windows/_?<property>=<value>
Example app call querying all windows with a class like "Mozilla[a-zA-Z]+Class": get/windows?class=Mozilla[a-zA-Z]+Class

| Window functions | App Call                                    |
| ---------------- | ------------------------------------------- |
| acivate          | set/windows?active=_                        |
| close            | set/windows/_?                              |
| hide             | set/windows/_?hidden=True                   |
| maximize         | set/windows/_?minMax=1                      |
| minimize         | set/windows/_?minMax=-1                     |
| restore          | set/windows/_?minMax=0                      |
| show             | set/windows/_?hidden=False                  |
| set alwaysontop  | set/windows/_?alwaysOntop=<on, off, toggle> |
| set bottom       | set/windows/_?stackPosition=bottom          |
| set top          | set/windows/_?stackPosition=top             |
| set caption      | set/windows/_?caption=<on, off>             |

Example app call adding and therewith managing a window detected by the shell hook:
set/windows?id=_&tile=<True, False>&title=<On, Off>&icon=<string>&view=<integer>

`_` is a context sensitive wildcard. In the context of the shell hook it is `lParam`, the id of the window, for wich the message was received.
