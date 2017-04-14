# Installation en mode master/slave

> L'objectif est de mettre en place Netdata sur un serveur maitre vers lequel chacun des esclaves va envoyer des metrics.

Note : empreinte mémoire : 
- pour le master : 15 Mb 
- pour les esclaves : 5 Mb

## Installation 

> Pour l'installation se référer au fichier Monitoring.md

## Configuration :

### Génération d' une clé :

> Achtung ! : On parle ici d'une clé visant à sécuriser les échanges, notez là donc bien précieusement !

On va d'abord installer uuidgen pour générer notre clé :

```bash
sudo apt install uuid-runtime
```

On génére la clé :

```bash
74239f23-e618-4721-a3fc-6bd7310cc19d
```

### Configuration du master :

On édite le fichier ```/etc/netdata/stream.conf``` (ligne 51) :

```haskell
#vi /etc/netdata/stream.conf
#:51
[11111111-2222-3333-4444-555555555555]
	# enable/disable this API key
    enabled = yes
    
    # one hour of data for each of the slaves
    default history = 3600
    
    # do not save slave metrics on disk
    default memory = ram
    
    # alarms checks, only while the slave is connected
    health enabled by default = auto

```

### Configuration des slaves :

On édite la aussi ```/etc/netdata/stream.conf``` (ligne 110):

```haskell
#vi /etc/netdata/stream.conf
#:110

[stream]
    # stream metrics to another netdata
    enabled = yes
    
    # the IP and PORT of the master
    destination = IP-DU-MASTER:19999
	
	# the API key to use
    api key = 11111111-2222-3333-4444-555555555555 
```

On coupe la génération de base de données locale au slave (car ils envoient tout au master) :

```haskell
#vi /etc/netdata/netdata.conf

[global]
    # on coupe la base de données locale
	memory mode = none

[health]
    # on coupe le health check
    enabled = no

```

> Note : On coupe toutes ces fonctions car elles sont effectuées par le master.
