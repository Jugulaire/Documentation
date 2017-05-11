# Installation Passbolt 

## Etapes :

1. Installation de Nginx
2. Installation de php-fpm
3. Installation de mysql
4. Mise en place de TLS
5. Mise en place pretty URL (cake php)
6. Installation de passbolt

### Installation Nginx :

```bash 
#As root
apt update && apt install nginx
```

### Installation de PHP
```bash
apt install php5-fpm php5-imagick php5-gnupg php5-memcached php5-gd php5-mysql
```

### installation de mySQL

```bash
# Installation mysql 
apt install mysql
mysql_install_db
/usr/bin/mysql_secure_installation
```
Place à la création des utilisateurs et des bases pour passbolt :

```sql
# Création de l'utilisateur pour passbolt
CREATE USER 'passbolt'@'localhost' IDENTIFIED BY 'password';
CREATE DATABASE passbolt;
CREATE DATABASE test_passbolt;
GRANT ALL PRIVILEGES ON  passbolt. * TO 'passbolt'@'localhost';
GRANT ALL PRIVILEGES ON test_passbolt. * TO 'passbolt'@'localhost';
```

### Mise en place de HTTPS (TLS)

> Note : Ici on génère un certificat auto-signé pour nos tests !
> Dans un cadre de production on utilisera let's encrypt.

#### Création d'un certificat (une commande) :

```bash
#Création du certificat
openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365
#Création d'un fichier ou le stocker
mkdir /etc/nginx/ssl
mv cert.pem /etc/nginx/ssl
mv key.pem /etc/nginx/ssl
```
#### Paramétrage de Nginx :

```nginx
#On active SSL ipv4 et ipv6
listen 443 ssl;
listen [::]:443 ssl;
#On ajoute les fichiers de certificat
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/key.pem;
```

### Activation de pretty URL :

Voici a quoi doit ressembler votre configuration dans le cas ou l'on utilise un sous domaine :

```nginx

# Serveur PASSBOLT 

server {
    listen   443;
	ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    server_name pass.passbolt.local;

    root   /var/www/html/passbolt/app/webroot/;
    index  index.php;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index   index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}

```

Et ici dans le cas ou on utilise un sous dossier :

```nginx
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	listen 443 ssl default_server;
	listen [::]:443 ssl default_server;
	 
	ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

	allow all;
	root /var/www/html/;
	server_name passbolt.local;
	
	#PASSBOLT
	
	location = /passbolt/manifest.php {
    		rewrite ^/passbolt/manifest.php$ /passbolt/webroot/manifest.php last;
    	}

	location /passbolt {
        	rewrite ^/passbolt(.+)$ /passbolt/app/webroot$1 break;
		index index.php;
        	try_files $uri $uri/ /passbolt/app/webroot/index.php?$args;
 
  		location ~ \.php$ {
     			try_files $uri =404;
     			include fastcgi_params;
			fastcgi_split_path_info ^(.+\.php)(/.+)$;
     			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			fastcgi_pass unix:/var/run/php5-fpm.sock;
     			fastcgi_index  index.php;
  		}	
	}
}
```
## Installation de passbolt :

Etapes :
- Installation de l'APP
- Création d'une clé GPG 
- Export de la clé dans l'app
- Paramétrage 
- Premier démarrage

### Installation de l'app :

```bash
cd /var/www/html
git clone https://github.com/passbolt/passbolt.git
chown -R www-data: passbolt
chmod +w -R app/tmp
chmod +w app/webroot/img/public
```

### Création des clés GPG :

```bash
su -s /bin/bash www-data
gpg --gen-key
#Prendre paramètres par défaut SANS PASSPHRASE
```
> Note : Mettre un email (même fictif) du même domaine que celui du serveur !!
> Ex je suis sur example.com => user@example.com

Tips : Installer haveged pour générer plus d'entropy et accélérer la génération de la clé GPG.

### Export des clés :
```bash
gpg --armor --export-secret-keys passbolt > /var/www/html/passbolt/app/Config/gpg/private.key
gpg --armor --export passbolt > /var/www/html/passbolt/app/Config/gpg/public.key
```
### Parametrage :

Connexion a la base de données :
```bash
cd /var/www/html
vi app/Config/database.php
cp app/Config/database.php.default app/Config/database.php
```
On remplis les parametres :
```php
public $default = array(
	'datasource' => 'Database/Mysql',
	'persistent' => false,
	'host' => 'localhost',
	'login' => 'username',
	'password' => 'password',
	'database' => 'passbolt'
);
```
Configuration du core :

```bash
cp app/Config/core.php.default app/Config/core.php
```

```php
Configure::write('App.fullBaseUrl','https://sous.domaine.tld')
```
> Note : ici on va spécifier le sous domaine sur lequelle on veut joindre passbolt.


Configuration des clé GPG :
```bash
cd /var/www/html
cp app/Config/app.php.default app/Config/app.php
```
```php
$config = [
		'GPG' => [
				'env' => [
						'setenv' => true,
						'home' => '/usr/share/httpd/.gnupg'
				],
				'serverKey' => [
						'fingerprint' => '2FC8945833C51946E937F9FED47B0811573EE67D',
						'public' => APP . 'Config' . DS . 'gpg' . DS . 'public.key',
						'private' => APP . 'Config' . DS . 'gpg' . DS . 'private.key',

				]
		]
```
En premier on modifie le chemin vers nos clé (exporté précédemment):
```php
'home' => /var/www/html/passbolt/app/Config/gpg/
```
On va changer le fingerprint de notre clé pour correspondre a celui de notre clé:
```bash
gpg --with-fingerprint app/Config/gpg/public.key
i```
## Lacement de passbolt :

On lance passbolt en tant que www-data pour être bien sûr que les droits sont bien configurés :
```bash
su -s /bin/bash -c "app/Console/cake install --no-admin" www-data
`i``
## Création d'un administrateur :
```bash
su -s /bin/bash www-data
cd 
 html/passbolt/app/Console/cake passbolt register_user -u bob@passbolt.local -f bob -l paterson -r admin
```
## Création d'un utilisateur normal :
```bash
su -s /bin/bash www-data
cd 
 html/passbolt/app/Console/cake passbolt register_user -u bob@passbolt.local -f bob -l paterson -r user
```
