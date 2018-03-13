
-- HOWTO:
-- after saving it, open with Script Editor (default) and run it

-- PREREQUISITES:
-- make sure your Keynote presentation is open in the background 

-- AFTER EXPORT:
-- if you can't open the file due to encoding errors, open with Sublime (or another a text editor) and then "File / Save with encoding / UTF8"

-- set AppleScript's text item delimiters to {return & linefeed, return, linefeed, character id 8233, character id 8232}


on find_and_replace_in_text(theText, theSearchString, theReplacementString)
    set AppleScript's text item delimiters to theSearchString
    set theTextItems to every text item of theText
    set AppleScript's text item delimiters to theReplacementString
    set theText to theTextItems as string
    set AppleScript's text item delimiters to ""
    return theText
end find_and_replace_in_text

-- Mark: This is used to encode line breaks into the flat CSV file
on encode_line_breaks(theText)
    --return find_and_replace_in_text(theText, {return & linefeed, return, linefeed, character id 8233, character id 8232}, {character id 8233, character id 8232})
    return find_and_replace_in_text(theText, {return & linefeed, return, linefeed, character id 8233, character id 8232}, "[LINEBREAK]")
end encode_line_breaks

-- Mark: This is used to encode various special characters 
on encode_char(this_char)
 set the ASCII_num to (the ASCII number this_char)
 set the hex_list to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
 set x to item ((ASCII_num div 16) + 1) of the hex_list
 set y to item ((ASCII_num mod 16) + 1) of the hex_list
 return ("%" & x & y) as string
end encode_char

-- this sub-routine is used to encode text 
on encode_text(this_text)
 set the standard_characters to "abcdefghijklmnopqrstuvwxyz0123456789.-_: ,"
 set the acceptable_characters to the standard_characters
 set the encoded_text to ""
 repeat with this_char in this_text
 if this_char is in the acceptable_characters then
 set the encoded_text to (the encoded_text & this_char)
 else
 set the encoded_text to (the encoded_text & encode_char(this_char)) as string
 end if
 end repeat
 return the encoded_text
end encode_text

-- utility method to trip trailing words (in our case trailing linebreak placeholders) 
on rstripString(theText, trimString)
	local theText, trimString, x
	try
		set x to count trimString
		try
			repeat while theText ends with trimString
				set theText to characters 1 thru -(x + 1) of theText as text
			end repeat
			return theText
		on error number -1700
			return ""
		end try
	on error eMsg number eNum
		error "Can't trimBoth: " & eMsg number eNum
	end try
end rstripString

on prepare_slide_note(slide_note)

 -- remove internal custom instruction words from our speaker notes 
 set slide_note to find_and_replace_in_text(slide_note, {"[CLICK]"}, "")
 
 -- encode line breaks to work with our CSV file. We'll manually do a find-all-and-replace in indesign to bring it back
 set slide_note to encode_line_breaks(slide_note)
 
 -- then check if slide has 3 or more linebreaks in a row, we know that is extra text at the bottom of speaker note we want to prune
 set technical_notes_linebreak_pattern to "[LINEBREAK][LINEBREAK][LINEBREAK]"
 if slide_note contains technical_notes_linebreak_pattern then
  set AppleScript's text item delimiters to technical_notes_linebreak_pattern
  set slide_note to text item 1 of slide_note
  set AppleScript's text item delimiters to ""
 end if
 
 --remove any double+ linebreaks so we don't generate extra empty bullets
set slide_note to find_and_replace_in_text(slide_note, {"[LINEBREAK][LINEBREAK]"}, "[LINEBREAK]")

 -- finally remove any trailing whitespace symbols from the end of the note
set slide_note to rstripString(slide_note, "[LINEBREAK]")
     
 return slide_note
end prepare_slide_note

tell application "Keynote"
	activate
	-- open (choose file)
	tell front document
		-- Get the name of the presentation.
		set thePresentationName to name
		
		-- Retrieve the titles of all slides.
		set theTitles to object text of default title item of every slide
		
		-- Retrieve the presenter notes for all slides.
		set theNotes to presenter notes of every slide
	end tell
end tell
set presenterNotes to "slideIndex,note,@imagePath" & linefeed
set projectPath to (path to home folder as text) & "Dropbox:indesign:"
repeat with a from 1 to length of theTitles
        set slideIndex to a as string
        if the length of slideIndex is 1 then
            set slideIndex to "00" & slideIndex
        else if the length of slideIndex is 2 then
            set slideIndex to "0" & slideIndex
        end if
		set slideNotes to item a of theNotes
		set slideNotes to prepare_slide_note(slideNotes)
        set imagePath to (projectPath & "slide:slide." & slideIndex & ".png")
		set presenterNotes to presenterNotes & a & ",\"" & slideNotes & "\",\"" & imagePath & "\"" & linefeed
end repeat

-- set the clipboard to presenterNotes
-- do shell script "pbpaste > ~/Dropbox/indesign/datamap.txt"
-- file -b --mime-encoding datamap.txt gets encoding, turns out it was iso-8859-1
-- do shell script "iconv -f ascii -t UTF-16LE < ~/Dropbox/indesign/datamap.txt > ~/Dropbox/indesign/datamap.utf8.txt"


set csvFile to projectPath & "datamap.csv"
set f to (open for access file csvFile with write permission)
set eof of f to 0 --> empty file contents if needed
--> now write the flag
write ((ASCII character 254) & (ASCII character 255)) to f --> not as Unicode text
--> now write the data
write presenterNotes to f as Unicode text
close access f