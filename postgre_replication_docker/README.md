# Docker compose pour postgres-sql en replication

Ce repo contient 2 fichiers compose pour déployer un serveur postgres-sql dans un conteneur docker ainsi qu'un serveur de replication.

> Ce repo se base sur [ce repo git](http://https://github.com/sameersbn/docker-postgresql)

### Note :
Il vous faudra modifier l'IP dans le fichier ``` postgres-rep-slave.yml```
(la partie ``` REPLICATION_HOST```)