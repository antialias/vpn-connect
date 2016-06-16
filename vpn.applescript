#!/usr/bin/osascript
on run argv
	tell application "System Events"
		-- get current clipboard contents as a string
		set CurrentClipboard to the clipboard as string
		
		-- set the clipboad to your password	
		
		-- start playing with the VPN	
		tell current location of network preferences
			
			-- set the name of the VPN service from your Network Settings
			set vpn_name to system attribute "vpn_service"
			-- determine current VPN connection status 	
			if (do shell script "scutil --nc status " & vpn_name) starts with "Connected" then
				do shell script "scutil --nc stop " & vpn_name
			else -- otherwise, connect to the VPN
				
				set vpnpass to do shell script "echo $(security find-generic-password -a vpn-password -s vpn-password -w)"
				if vpnpass is "" then
					display dialog "VPN password" default answer ""
					set vpnpass to text returned of result
					do shell script "security add-generic-password -a vpn-password -s vpn-password -w " & vpnpass
				end if
				set the clipboard to vpnpass
				do shell script "scutil --nc start " & vpn_name
				-- wait 10 seconds before pasting in the password
				delay 1
				
				tell application id "com.apple.systemevents"
					-- paste clipboard contents into password box
					keystroke "v" using {command down}
					-- press "Enter"
					keystroke (key code 36)
					delay 1
					-- wait 10 seconds to connect	
					delay 3
					-- determine current VPN connection status (after providing password)
					set nowConnected to (do shell script "scutil --nc status " & vpn_name) starts with "Connected"
					
					-- if we're now connected ...	
					if nowConnected then
						
						-- press "Enter" again to get rid of a dialog confirmation prompt, if one exists
						keystroke (key code 36)
						
						-- now, execute any other commands you want (ping a server to check its status, open mail, etc.)	
						
					end if
				end tell
				
			end if
			
		end tell
		-- now reset the clipboard to what it was before we started
		set the clipboard to CurrentClipboard
	end tell
end run
