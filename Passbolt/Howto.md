# Installation Passbolt 

## Etapes :

1. Installation de Nginx
2. Installation de php-fpm
3. Installation de mysql
4. Mise en place de TLS
5. Installation de passbolt

### Installation serveur web :

1. Nginx

```bash 
#As root
apt update && apt install nginx
```

2. php
```bash
apt install php5-fpm php5-imagicki php5-gnupg php5-memcachedi php5-gd php5-mysql
```

3. Mysql 

```bash
# Installation mysql 
apt install mysql
mysql_install_db
/usr/bin/mysql_secure_installation
```
Place a la création des utilisateurs et des bases pour passbolt :

```sql
# Création de l'utilisateur pour passbolt
CREATE USER 'passbolt'@'localhost' IDENTIFIED BY 'password';
CREATE DATABASE passbolt;
CREATE DATABASE test_passbolt;
GRANT ALL PRIVILEGES ON  passbolt. * TO 'passbolt'@'localhost';
GRANT ALL PRIVILEGES ON test_passbolt. * TO 'passbolt'@'localhost';
```

4. TLS :

> Note : Ici on génére un certificat autosigné pour nos tests !
> Dans un cadre de production on utilisera let's encrypt.

Création d'un certificats (une commande) :

```bash
#Création du certificat
openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365
#Création d'un fichier ou le stocker
mkdir /etc/nginx/ssl
mv cert.pem /etc/nginx/ssl
mv key.pem /etc/nginx/ssl
```
Paramétrage de Nginx :

```nginx
#On active SSL ipv4 et ipv6
listen 443 ssl;
listen [::]:443 ssl;
#On ajoute les fichiers de certificat
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/key.pem;
```

## Activation de pretty URL :

## Installation de passbolt :

Etapes :
- Installation de l'APP
- Création d'une clé GPG 
- Export de la clé
- Parametrage 
- premier démarrage

### Installation de l'app :

```bash
cd /var/www/html
git clone https://github.com/passbolt/passbolt.git
chown -R www-data: passbolt
chmod +w -R app/tmp
chmod +w app/webroot/img/public
```

### Création des clé GPG :

```bash
su -s /bin/bash www-data
gpg --gen-key
#Prendre parametres par défaut SANS PASSPHRASE
```

### Export des clé :
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
En premier on modifie le chemin vers nos clé (éxporté précédement):
```php
'home' => /var/www/html/passbolt/app/Config/gpg/
```
On va changer le fingerprint de notre clé pour correspondre a celui de notre clé:
```bash
gpg --with-fingerprint app/Config/gpg/public.key
```
## Lacement de passbolt :
i
On lance passbolt en tant que www-data pour être bien sur que les droits sont bie nconfiguré :
```bash
su -s /bin/bash -c "app/Console/cake install --no-admin" www-data
```
