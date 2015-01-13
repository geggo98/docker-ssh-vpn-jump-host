# docker-ssh-vpn-jump-host

A secured ssh based VPN in a Docker container. Works only as 
jump host for port forwarding and SOCKS proxy but provides no shell.

Idea: SSH VPN jump host for port forwarding
===========================================

This docker file provides a pure jump host. This means it
can only be used to connect to other servers using
ssh port fowarding. It has no shell available and 
cannot run any commands.

Connecting
==========

Connect from Linux
------------------

Open the command line and run

1. `ssh -N -L xxx:nnnnnn:yyy -p 22022 vpn@name-of-server`

   Where 
   
| Option         | Description                          |
| -------------- | -------------------------------------|
| nnnnnn:yyy     | The remote server you want to access |
| xxx            | The local port number                |
| name-of-server | The name of the jump gateway server  |

   You can then access the remote server on port xxx on your 
   local system.

2. `ssh -N -D 1080 -p 22022 vpn@name-of-server`
    
   You can then add "localhost:1080" as a socks 4 proxy to
   your local web browser. All traffic will be tunneled to
   the vpn gateway server.


Connect from Mac OS X
---------------------

Install a current ssh version using [homebrew][1]:

```shell
    brew tap homebrew/dupes
    brew install openssh \
      --with-brewed-openssl --with-keychain-support
```

Then continue with the steps for Linux.

[1]: http://brew.sh/

Connect from Windows
--------------------

*Attention:* PuTTY does not support the required encryption 
levels used on this server.

Connect using [KiTTY SSH][2] or [MobaXTerm][3].

[2]: http://www.9bis.net/kitty/
[3]: http://mobaxterm.mobatek.net/

### KiTTY SSH

Configure a new session with port forwarding. Under "SSH"
choose "Don't start a shell or command at all".

### MobaXTerm

Create a new connection. Under "Advanced settings" choose 
"Conncet through SSH gateway (jump host)"

