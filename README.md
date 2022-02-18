# Bash Script to help with capture the flags

This is a bash script I made to help me with capture the flags. It is something that I can run while I go and make a cup of tea and hopefully
when I get back it will have some results. This saves me time from having to run commands seperately as well. I also added a way to
generate reverse shells using msfvenom and then automatically start a listener too with metasploit. It isnt the most well designed bash script
however I am using it for personal use and it does the job!

The script allows you to run nmap either with a vulnerability scan or without one and then it will scan for ports. If a port like
port 80 was found then it will attempt a directory bruteforce, which in this case requires gobuster as I thought this is a
better tool as it uses multi thread therefore making the process faster! It will also run smbmap and enum4linux if the ports are available

Requirements:
- gobuster
- smbmap
- enum4linux
