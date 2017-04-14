# Sécurisation serveur 

## Mise en place de Portsentry
Portsentry permet de bloquer les scan de ports (nmap ou masscan)
### Installation :

```bash
apt-get update
apt-get install portsentry
```
### Paramétrage :
On édite ```/etc/portsentry/portsentry.conf``` avec les paramêtres suivants : 
On passe le blocage en UDP et TCP a 1 (activation)
```haskell
BLOCK_UDP="1"
BLOCK_TCP="1"
```
On décommente cette ligne :

```haskell
# iptables support for Linux
KILL_ROUTE="/sbin/iptables -I INPUT -s $TARGET$ -j DROP"
```
On édite ensuite ```/etc/default/portsentry``` :

```haskell
# /etc/default/portsentry
#
# This file is read by /etc/init.d/portsentry. See the portsentry.8
# manpage for details.
#
# The options in this file refer to commandline arguments (all in lowercase)
# of portsentry. Use only one tcp and udp mode at a time.
#
TCP_MODE="atcp"
UDP_MODE="audp"

```
On va maintenant whitelisté les IP autorisée a scanner le serveur dans ```/etc/portsentry/portsentry.ignore.static``` 
```haskell
# Put hosts in here you never want blocked. This includes the IP addresses
# of all local interfaces on the protected host (i.e virtual host, mult-home)
# Keep 127.0.0.1 and 0.0.0.0 to keep people from playing games.
#
# Upon start of portsentry(8) via /etc/init.d/portsentry this file 
# will be merged into portsentry.ignore.
#
# PortSentry can support full netmasks for networks as well. Format is:
#
# <IP Address>/<Netmask>
#
# Example:
#
# 192.168.2.0/24
# 192.168.0.0/16
# 192.168.2.1/32
# Etc.
#
# If you don't supply a netmask it is assumed to be 32 bits.
#
#
127.0.0.1/32
0.0.0.0
192.168.122.1/24
```
>** NOTE : Il est important de whitelist les IP car sinon portsentry va les bannir avec une regle iptables ! On ne pourra donc plus accéder au serveur !**

On redemarre portsentry :

```bash
service portsentry restart
```
> Sinon j'ai ecris un script qui fait déjà le travail ..

