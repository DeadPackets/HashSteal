<h1 align="center">HashSteal</h1>
<p align="center">
An automated USB attack on locked Windows devices allowing the capture of hashed passwords by abusing IPv6 and DNS.
</p>

---

## :warning: DISCLAIMER :warning:

The scripts and attack methadology described in this repository, my slides and my videos is purely for educational and research purposes. Do not use the scripts and attacks unless you are authorized to do so or if it is for educational purposes.

I will not be held responsible for your actions.

## Slides, talk and demo

- The slides are in this repository as `GISEC_2019_Advanced_USB_Attacks.pdf`

- Full GISEC talk and presentation
[![GISEC 2019 talk](https://img.youtube.com/vi/EKp4WVupukY/maxresdefault.jpg)](https://youtu.be/EKp4WVupukY)

- Detailed demo and analysis of the attack [![GISEC 2019 talk](https://img.youtube.com/vi/NO6pEW7Ad_Q/maxresdefault.jpg)](https://youtu.be/NO6pEW7Ad_Q)

## The Attack

The HashSteal attack abuses behavior in Windows where it prefers IPv6 nameservers over any preconfigured IPv4 nameservers and gateways.

By creating a new IPv6 network over USB, the Windows device connects to our network and we can poison DNS replies in order to trigger an HTTP request to a device that we control.

Once the HTTP request is made, we can invoke NTLM authentication on the request which makes the Windows device automatically send over hashed credentials that we can capture and crack offline or online.

## How to run

The scripts in this repo depend on [P4wnP1 A.L.O.A](https://github.com/RoganDawes/P4wnP1_aloa) to be running on a Raspberry Pi Zero W.

- `ipv6_pwn_start.sh` - This is the attack script to be set to run on boot in P4wnP1.

- `ipv6_pwn_start_demo.sh` - This is the attack script to be run manually and interactively from a tmux session within the P4wnP1 over SSH or directly through a terminal.

In order for the script to work, you must have P4wnP1 set to emulate Keyboard, Ethernet and Mouse.

## Tools used

- [Responder](https://github.com/lgandx/Responder) - Used to poison WPAD requests and capture NTLM hashes.

- [mitm6](https://github.com/dirkjanm/mitm6) - Used to create our IPv6 network and DNS server to control traffic and DNS.

- [JohnTheRipper](https://github.com/openwall/john) - Used to crack NTLM hashes once they have been captured.

## Credits

HashSteal would not be possible without the research by the great people at Fox-IT with their reasearch on exploiting IPv4 networks using IPv6.

Check out their awesome research on this attack [here](https://www.fox-it.com/nl-en/blog-6-mitm6-compromising-ipv4-networks-via-ipv6/).
