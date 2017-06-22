# Installation de PHP server Monitor

[TOC]

## Mysql

On va créer un utilisateur et une base pour l'app :

```
sudo mysql -h localhost -p
CREATE USER 'phpmon'@'localhost' IDENTIFIED BY 'Strong_Password';
CREATE DATABASE phpmon;
GRANT ALL PRIVILEGES ON piwik. * TO 'phpmon'@'localhost';
```

## Téléchargement et installation 

On commence par télécharger l'archive

```bash
wget https://downloads.sourceforge.net/project/phpservermon/phpservermon/phpservermon-3.2.0.zip?r=http%3A%2F%2Fwww.phpservermonitor.org%2Fdownload%2F&ts=1496997497&use_mirror=netix
```

On la décompresse 

```bash
unzip phpservermon-3.2.0.zip
```

On la place dans ``/var/www/html/phpservermon``

```bash
mv phpservermon-3.2.0 /var/www/html/phpservermon
```

<div style="page-break-after: always;"></div>

## Configuration de Nginx 

Voici la configuration que utilisé pour Nginx :

```nginx
 location /phpmon {
                alias /var/www/html/phpservermon/;
                index index.php;

        }
        location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
```

## Installation 

Rendez-vous a l'adresse ``mon-domaine.tld/phpmon`` 

Un assistant va vous demander de saisir les identifiants de la base de données avant de crée un compte administrateur. 



