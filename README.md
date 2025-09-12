Auto Network Switch for macOS

Automatically switch between Ethernet and Wi-Fi on macOS.
If a working Ethernet connection is detected, Wi-Fi will be disabled.
If Ethernet is unavailable or has no connectivity, Wi-Fi will be enabled.

	•	MAX_WAIT: number of seconds to wait at boot until a network service becomes available (default: 30).
	•	Ping target: the script uses 8.8.8.8 to validate connectivity. You can change it inside the function check_connectivity().

Example output
Waiting for network service availability (max 30 sec)...
Network interface detected.
Wi-Fi : en0 | Ethernet : en7
Ethernet IP Address : 192.168.1.20
Current Wi-Fi state : On
Ethernet connection functional.
Disabling Wi-Fi...


(Optional) Run it automatically at boot using launchd:
Create /Library/LaunchDaemons/com.auto.networkswitch.plist with the following content:

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.auto.networkswitch</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/networkswitch.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>30</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>


Then load it:
sudo launchctl load /Library/LaunchDaemons/com.auto.networkswitch.plist
