/**
 *	AHK List implementation
 *	Copyright (c) 2012 Joshua Fuhs
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * This is an admittedly poor list implementation, but I was new to AHK,
 * and I had seen several examples of this already used.
 * The lists being operated on should not be larger than a few hundred, 
 * and preferably no larger than one hundred.
 */
 

List_new() {
	Global
	Return ""
}

List_prepend( ByRef l, e ) {
	l := e . "`;" . l
	Return
}

List_append(ByRef l, e) {
	l := l . e . "`;"
	Return
}

; Insert at position immediately preceding index p
List_insert(ByRef l, e, p) {
	Local arr, search, replace
	If ( p = 0)
		return List_prepend(l, e)
	StringSplit arr, l, `;
	if ( p >= arr0 - 1 )
		return List_append(l, e)
	p += 1
	search := arr%p% . ";"
	replace := e . ";" . search
	StringReplace, l, l, %search%, %replace%
}

List_remove(ByRef l, e) {
	Local search
	search := "" . e . ";"
	StringReplace, l, l, %search%,
	return
}


List_removeAt(ByRef l, p) {
	Local arr, search
	StringSplit arr, l, `;
	if( p >= arr0 - 1)
		Return
	p += 1
	search := arr%p% . ";"
	StringReplace, l, l, %search%,
}

List_find(ByRef l, e) {
	Local arr, arr0
	StringSplit arr, l, `;
	Loop, % (arr0 - 1) {
		If arr%A_Index% = %e%
			Return (A_Index - 1)
	}
	Return -1
}

List_dump(l) {
	Local result
	StringReplace, result, l, `;, %A_Space%, All
	Return result
}

List_get(l, p) {
	Local arr
	StringSplit arr, l, `;
	If( p >= arr0 )
		Return ""
	p += 1
	Return arr%p%
}

List_size(l) {
	Local arr, arr0
	StringSplit arr, l, `;
	Return (arr0 - 1)
}
