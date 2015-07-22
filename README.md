# docker-ssh-vpn-jump-host

A secured ssh based VPN in a Docker container. Works only as 
jump host for port forwarding and SOCKS proxy but provides no shell.

It can either be used to access services on a remote host or
a remote access in a secure way.

Or it can be used to publish services inside a docker container
with ssh. I this case, there should be at least two docker
ontainers: One running the service you want to access from the
outside and one running the ssh service. 

The big advantage of having ssh in a separate Docker container is that 
the ssh container can be kept at the most current version while the rest
of the system can stay at a stable state. So if there are some security
updates, it is sufficient to only update the ssh Docker container and
keep the rest of the system untouched.

With the ssh Docker container it is also possible to update ssh from remote 
without risking to lock yourself out. Just spawn two instances of the ssh
Docker container, then connect to the first and update the second and 
then vice versa. So there is always a backup in case the update fails and
ssh won't start in the updated container.

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

### Autossh

Instead of the plain command line ssh, you can also use [autossh][4]. Autossh automatically restarts the tunnel when the connection temporarily goes down. It is available to all major platforms (on Windows autossh is available as a Cygwin package and can even [run as a Windows service][5]).

[4]: http://www.harding.motd.ca/autossh/
[5]: http://www.matthanger.net/2008/04/creating-persistent-ssh-tunnels-in.html

# News

| Date       | Remark|
|------------|-------|
| 2015-07-22 | The provided configuration is already imune against the [MaxAuthRetries attack][6]. |

[6]: https://kingcope.wordpress.com/2015/07/16/openssh-keyboard-interactive-authentication-brute-force-vulnerability-maxauthtries-bypass/


