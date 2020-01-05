/*
:title:     bug.n/configuration/dwm
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class Configuration {
  __New() {
    Global logger
    
    this.name := "dwm"
    
    /* appearance */
    ;; static const unsigned int borderpx  = 1;        /* border pixel of windows */
    ;; static const unsigned int snap      = 32;       /* snap pixel */
    ;; static const int showbar            = 1;        /* 0 means no bar */
    this.showbar := True
    ;; static const int topbar             = 1;        /* 0 means bottom bar */
    this.topbar := True
    ;; static const char *fonts[]          = { "monospace:size=10" };
    this.fonts := [name: "monospace", size: 10]
    ;; static const char dmenufont[]       = "monospace:size=10";
    ;; static const char col_gray1[]       = "#222222";
    col_gray1 := "222222"
    ;; static const char col_gray2[]       = "#444444";
    col_gray2 := "444444"
    ;; static const char col_gray3[]       = "#bbbbbb";
    col_gray3 := "bbbbbb"
    ;; static const char col_gray4[]       = "#eeeeee";
    col_gray4 := "eeeeee"
    ;; static const char col_cyan[]        = "#005577";
    col_cyan  := "005577"
    ;; static const char *colors[][3]      = {
      /*               fg         bg         border   */
    ;;  	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
    ;;  	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  }, };
    this.colors := {SchemeNorm: [col_gray3, col_gray1, col_gray2]
                  , SchemeSel:  [col_gray4, col_cyan,  col_cyan]}
    
    /* tagging */
    ;; static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
    this.tags := ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    ;; static const Rule rules[] = {
      /* xprop(1):
       *	WM_CLASS(STRING) = instance, class
       *	WM_NAME(STRING) = title
       */
      /* class      instance    title       tags mask     isfloating   monitor */
    ;;  	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
    ;;  	{ "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 }, };
    this.rules := [[class: "Gimp",    instance: "", title: "",  tagsMask: 0,      isFloating: 1,  monitor: -1]
                 , [class: "Firefox", instance: "", title: "",  tagsMask: 1 << 8, isFloating: 0,  monitor: -1]]
    
    /* layout(s) */
    ;; static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
    this.mfact := 0.55
    ;; static const int nmaster     = 1;    /* number of clients in master area */
    this.nmaster := 1
    ;; static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
    
    ;; static const Layout layouts[] = {
      /* symbol     arrange function */
    ;;  	{ "[]=",      tile },    /* first entry is default */
    ;;  	{ "><>",      NULL },    /* no layout function means floating behavior */
    ;;  	{ "[M]",      monocle }, };
    this.layouts := [[symbol: "[]=",  arrangeFunction: "tile"]
                   , [symbol: "><>",  arrangeFunction: ""]
                   , [symbol: "[M]",  arrangeFunction: "monocle"]]
    
    /* key definitions */
    ;; #define MODKEY Mod1Mask
    ;; #define TAGKEYS(KEY,TAG) \
      { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
      { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
      { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
      { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },
    
    /* helper for spawning shell commands in the pre dwm-5.0 fashion */
    ;; #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
    
    /* commands */
    ;; static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
    ;; static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
    ;; static const char *termcmd[]  = { "st", NULL };
    
    logger.info("<b>" . this.name . "</b> configuration loaded.", "Configuration.__New")
  }
}

;; static Key keys[] = {
 	/* modifier                     key        function        argument */
;;  	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
;;  	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
!+Enter::Run, %ComSpec% /c
;;  	{ MODKEY,                       XK_b,      togglebar,      {0} },
!b::togglebar()
;;  	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
!j::focusstack(+1)
;;  	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
!k::focusstack(-1)
;;  	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
!i::incmaster(+1)
;;  	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
!d::incmaster(-1)
;;  	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
!h::setmfact(-0.05)
;;  	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
!l::setmfact(+0.05)
;;  	{ MODKEY,                       XK_Return, zoom,           {0} },
!Enter::zoom()
;;  	{ MODKEY,                       XK_Tab,    view,           {0} },
!Tab::view()
;;  	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
!+c::killclient()
;;  	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
!t::setlayout(1)
;;  	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
!f::setlayout(2)
;;  	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
!m::setlayout(3)
;;  	{ MODKEY,                       XK_space,  setlayout,      {0} },
!Space::setlayout()
;;  	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
!+Space::togglefloating()
;;  	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
!0::view(0)
;;  	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
!+0::tag(0)
;;  	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
!,::focusmon(-1)
;;  	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
!.::focusmon(+1)
;;  	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
!+,::tagmon(-1)
;;  	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
!+.::tagmon(+1)
;;  	TAGKEYS(                        XK_1,                      0)
;;  	TAGKEYS(                        XK_2,                      1)
;;  	TAGKEYS(                        XK_3,                      2)
;;  	TAGKEYS(                        XK_4,                      3)
;;  	TAGKEYS(                        XK_5,                      4)
;;  	TAGKEYS(                        XK_6,                      5)
;;  	TAGKEYS(                        XK_7,                      6)
;;  	TAGKEYS(                        XK_8,                      7)
;;  	TAGKEYS(                        XK_9,                      8)
Loop, 9 {
  Hotkey, !%A_Index%, Func("view").Bind(A_Index)
  Hotkey, !^%A_Index%, Func("toggleview").Bind(A_Index)
  Hotkey, !+%A_Index%, Func("tag").Bind(A_Index)
  Hotkey, !^+%A_Index%, Func("toggletag").Bind(A_Index)
}
;;  	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} }, };
!+q::ExitApp
 
/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
;; static Button buttons[] = {
	/* click                event mask      button          function        argument */
;; 	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
;; 	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
;; 	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
;; 	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
;; 	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
;; 	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
;; 	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
;; 	{ ClkTagBar,            0,              Button1,        view,           {0} },
;; 	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
;; 	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
;; 	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} }, };
