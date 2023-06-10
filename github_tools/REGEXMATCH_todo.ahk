



/*an updated regular expression that will match any string that starts with "Main.New(" followed by any number of characters (including letters, numbers, spaces, and special characters) enclosed in double quotes, and ending with a closing parenthesis:
css
Copy code
Main\.New\("[^"]*"\)
This expression will match any string that starts with "Main.New(" followed by any number of characters enclosed in double quotes, as long as the characters inside the quotes do not include a closing quote (represented by [^"]*). This means that the characters inside the quotes can include spaces and multiple words.

Here's an updated example script that uses this regular expression:

swift
Copy code*/

strings := "Some text Main.New(`"abc 123`") more text Main.New(`"def ghi 456`") even more text"
regex := "Main\.New\(`"[^`"]*`"\)"
/*
*/
; Use RegExMatchAll to find all matches in the string
if (RegExMatch(strings, regex, &matches)) {
    ; Loop through each match and display the matched string
    Loop matches.Length 
        {
            MsgBox "Match #" A_Index ": " matches[A_Index]
        }
}
else {
    MsgBox "No matches found."
}
/*
This script will display two message boxes, one for each match found:

less
Copy code
Match #1: Main.New("abc 123")
Match #2: Main.New("def ghi 456")

*/



/*string := "Some text Main.New(\"abc123\") more text Main.New(\"def456\") even more text"
regex := "Main\.New\(\".*\"\)"

; Use RegExMatchAll to find all matches in the string
if (RegExMatchAll(string, regex, matches)) {
    ; Loop through each match and display the matched string
    Loop % matches.Count()
        MsgBox % "Match #" A_Index ": " matches[A_Index]
}
else {
    MsgBox % "No matches found."
}
