
Test_check(Condition, msg) {
	Global
	If Condition
		Return
	Log_bare(msg)
	Exit, 1
}


Log_init("List.test.txt", True)

testlist := List_new()
Log_bare("new list: " . List_dump(testlist))
Test_check(List_dump(testlist) = "", "Test 1 failure")
If Not (List_dump(testlist) = "" ) 
	Log_bare("Test 1 failure")
List_append(testlist, "abc")
Log_bare("appended 'abc': " . List_dump(testlist))
If Not (List_dump(testlist) = "abc " ) 
	Log_bare("Test 2 failure")
List_append(testlist, "def")
Log_bare("appended 'def': " . List_dump(testlist))
If Not (List_dump(testlist) = "abc def " ) 
	Log_bare("Test 3 failure")
List_append(testlist, "ghi")
List_remove(testlist, "abc")
Log_bare("removed 'abc': " . List_dump(testlist))
If Not (List_dump(testlist) = "def ghi " ) 
	Log_bare("Test 4 failure")
List_append(testlist, "jkl")
List_remove(testlist, "ghi")
Log_bare("add 'jkl', remove 'ghi': " . List_dump(testlist))
If Not (List_dump(testlist) = "def jkl " ) 
	Log_bare("Test 5 failure")
List_append(testlist, "mno")
List_remove(testlist, "mno")
Log_bare("add and remove 'mno': " . List_dump(testlist))
If Not (List_dump(testlist) = "def jkl " ) 
	Log_bare("Test 6 failure")
List_prepend(testlist, "12345")
Log_bare("prepend '12345': " . List_dump(testlist))
If Not (List_dump(testlist) = "12345 def jkl ")
	Log_bare("Test 7 failure")
List_insert(testlist, "xyz", 0)
List_insert(testlist, "Happy", 1)
List_insert(testlist, "Blah", 5)
List_insert(testlist, "10", 10)
Log_bare("Attempt multiple inserts by index: " . List_dump(testlist))
If Not (List_dump(testlist) = "xyz Happy 12345 def jkl Blah 10 ")
	Log_bare("Test 8 failure")
List_removeAt(testlist, 0)
List_removeAt(testlist, 1)
List_removeAt(testlist, 2)
List_removeAt(testlist, 3)
List_removeAt(testlist, 10)
Log_bare("Attempt multiple removals by index: " . List_dump(testlist))
If Not (List_dump(testlist) = "Happy def Blah ")
	Log_bare("Test 9 failure")
If Not (List_find(testlist, "Happy") = 0)
	Log_bare("Test 10 failure")
If Not (List_find(testlist, "def") = 1)
	Log_bare("Test 11 failure")
If Not (List_find(testlist, "Blah") = 2)
	Log_bare("Test 12 failure")
If Not (List_find(testlist, "nonexistent") = -1)
	Log_bare("Test 13 failure")
If Not (List_size(testlist) = 3)
	Log_bare("Test 14 failure")
If Not (List_get(testlist, 0) = "Happy")
	Log_bare("Test 15 failure")
If Not (List_get(testlist, 1) = "def")
	Log_bare("Test 16 failure")
If Not (List_get(testlist, 2) = "Blah")
	Log_bare("Test 17 failure")
If Not (List_get(testlist, 3) = "")
	Log_bare("Test 18 failure")



Return

#Include Log.ahk
#Include List.ahk