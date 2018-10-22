#!/bin/sh

# Scripts that executes tcpdump or a similar utility on a remote server
# and transmits the data back over SSH to a local wireshark instance.
#
# Control-C to stop and exit
# x.veiga@udc.es, 2018-10-22

# Login options
USERLOGIN="vx"
SERVERIP="88.5.101.133"
PORT=22

# Misc
USESUDO="sudo -S" # Uncomment to use sudo
NAMEDPIPE="/tmp/remotecap" # Named pipe to communicate locally with wireshark

# Capture settings
TCPDUMPOPTS="-s0 -U -w - 'not port 22'" # tcpdump options
WIRESHARKCMD="wireshark -i $NAMEDPIPE -k"

savettyoptions ()
{
    STTY_OPTS=$(stty -g)
}

loadttyoptions ()
{
    stty $STTY_OPTS
}

start_wireshark ()
{
    $WIRESHARKCMD& # Run wireshark on background
    WIRESHARKPID=$!
}

ssh_sudo_connect ()
{
    savettyoptions # Store tty opts to restore them later
    stty -echo # Disable echo to hide the password, as sudo -S uses stdin
    # read -r SSHPASS
    ssh $USERLOGIN@$SERVERIP "$USESUDO tcpdump $TCPDUMPOPTS" > $NAMEDPIPE
    loadttyoptions # Restore tty
}

trap_sigint ()
{
    echo 'Caught SIGINT. Closing wireshark.'
    echo
    kill -TERM $WIRESHARKPID
    #kill -TERM -$$
    echo "Deleting named pipe ($NAMEDPIPE)"
    rm $NAMEDPIPE
    loadttyoptions
    echo
    exit 2
}

main ()
{
    trap trap_sigint 1 2 3 15 # Setup SIGINT exit
    mkfifo /tmp/remotecap # Create named pipe
    echo "Launching wireshark with $NAMEDPIPE as source."
    start_wireshark
    echo
    echo "Will SSH to $USERLOGIN@$SERVERIP, port $PORT."
    echo "You may need to enter the ssh and sudo passwords next:"
    echo
    ssh_sudo_connect
}

main
