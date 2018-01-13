
/*
 * Measure the minimum delay between button presses.
 * 
 * Minimum observed delay: 80ms (2012/11/23)
 */


Start_Day:=A_YDay
Last_Time:= (((((((A_YDay - Start_Day) * 24 ) + A_Hour ) * 60) + A_Min) * 60) + A_Sec) * 1000 + A_MSec
Min_Delay:=1000000


MsgBox, ms base: %Last_Time%

Return


r::
	Cur_Time := (((((((A_YDay - Start_Day) * 24 ) + A_Hour ) * 60) + A_Min) * 60) + A_Sec) * 1000 + A_MSec
	Difference := Cur_Time - Last_Time

	If (Difference < Min_Delay)
		Min_Delay := Difference

	Last_Time := Cur_Time
	Return

q::
	MsgBox, Min_Delay: %Min_Delay%
	ExitApp
