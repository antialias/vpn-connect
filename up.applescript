#!/usr/bin/osascript
on run argv
	tell application "System Events"
		-- get current clipboard contents as a string
		set CurrentClipboard to the clipboard as string
		-- start playing with the VPN
		tell current location of network preferences
			-- set the name of the VPN service from your Network Settings
			set vpn_name to system attribute "vpn_service"
			if (do shell script "scutil --nc status " & vpn_name) starts with "Connected" then
				return
			end if
			-- determine current VPN connection status
			set vpnpass to do shell script "echo $(security find-generic-password -a vpn-password -s vpn-password -w)"
			if vpnpass is "" then
				display dialog "VPN password" default answer ""
				set vpnpass to text returned of result
				do shell script "security add-generic-password -a vpn-password -s vpn-password -w " & vpnpass
			end if
			-- set the clipboad to your password
			set the clipboard to vpnpass
			do shell script "scutil --nc start " & vpn_name
			delay 1 -- wait 1 second before pasting in the password
			tell application id "com.apple.systemevents"
				keystroke "v" using {command down} -- paste clipboard contents into password box
				keystroke (key code 36) -- press "Enter"
				delay 4 -- wait 4 seconds to connect
				-- determine current VPN connection status (after providing password)
				set nowConnected to (do shell script "scutil --nc status " & vpn_name) starts with "Connected"
				if nowConnected then
					-- press "Enter" again to get rid of a dialog confirmation prompt, if one exists
					keystroke (key code 36)
				end if
			end tell
		end tell
		-- now reset the clipboard to what it was before we started
		set the clipboard to CurrentClipboard
	end tell
end run
