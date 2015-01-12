on log_err(message)
	display notification message
	log message
end log_err

on run
	try
		tell application "Mail"
			set theSelection to selection
			
			repeat with theMessage in theSelection
				set messageText to (content of theMessage)
				set theSubject to the subject of theMessage
				set theMessageID to the message id of theMessage
				
				do shell script "~/bin/amail2trello.rb " & quoted form of theSubject & " " & quoted form of theMessageID & " " & quoted form of messageText
			end repeat
			
		end tell
	on error errmsg
		my log_err("Something went wrong: " & errmsg)
		
	end try
end run