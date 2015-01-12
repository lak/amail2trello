on log_err(message)
	display notification message
	log message
end log_err

-- Gotten from http://www.macosxautomation.com/applescript/sbrt/sbrt-09.html
-- modified to use temp files
on write_to_file(thisData)
  -- set targetFile to (path to "temp" from user domain as text) & (make new name) 
  try
    -- set targetFile to (path to temporary items) & (make new name) 
    -- set targetFile to (path to "temp" from user domain as text) & (make new name) 
    set targetFile to (path to "temp" from user domain as text) & "amail2trello.txt"

    set the targetFile to the targetFile as string
    set the open_target_file to open for access file targetFile with write permission
    set eof of the open_target_file to 0 -- always rewrite, if that comes up
    write thisData to the open_target_file starting at eof
    close access the open_target_file
    return targetFile
  on error errmsg
    my log_err("Could not write file: " & errmsg)

    try
      close access file target_file
    end try
    return false
  end try
end write_to_file

on run
	try
		tell application "Mail"
			set theSelection to selection
			
			repeat with theMessage in theSelection
				set theSource to (source of theMessage)
				set theContent to content of theMessage
				set theSubject to the subject of theMessage
				set theMessageID to the message id of theMessage

        -- Store the full text content in tmp, rather than passing it
        set sourceFile to my write_to_file(theSource)
				
				do shell script "~/bin/amail2trello.rb " & sourceFile & " " & quoted form of theSubject & " " & quoted form of theMessageID & " " & quoted form of theContent
        exit repeat -- only do the first message
			end repeat
			
		end tell
	on error errmsg
		my log_err("Could not create card from message: " & errmsg)
		
	end try
end run
