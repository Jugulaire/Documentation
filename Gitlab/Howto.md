# Installation Gitlab 

Etapes :

1. Installation des dépendances 
2. Installation de Gitlab
3. Paramétrage de Gitlab
4. Mise en place du proxy
5. Troubleshooting

## I - Installation des dépendances :

```bash
sudo apt-get install curl openssh-server ca-certificates postfix
```

## II - Installation du paquet :

```bash
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get install gitlab-ce
```

## III - Paramétrage :

Note : On souhaite ici utilisé un Proxy Nginx car notre serveur accueil plusieurs services web.
On souhaite donc une arborescence (avec des sous dossiers) de ce genre :
```
mondomaine.com : Site web
|---> modomaine.com/gitlab : Pour notre Git
|---> monodmaine.com/something : Pour un autre service
+---> etc...
```
Dans ``` /etc/gitlab/gitlab.rb ``` on va modifier ces lignes :

#### le paramétre : ```external_url``` :

```ruby
# Si on souhaite joindre gitlab avec :
# Http://mon-domaine.com
# Mettre ceci :
external_url "http://mon-domaine.com"
# Si on souhaite joindre notre gitlab par un URL du type :
# http://mon-domaine.com/gitlab
# Mettre ceci :
external_url "http://gitlab.example.com/gitlab"
```

#### le paramétre ```listen_adresses```:

```ruby
# Si on ne passe pas par un proxy :
nginx['listen_addresses'] = ["0.0.0.0", "[::]"] # Ecoute sur toutes les ipv4 et ipv6
# Si on passe par un proxy : 
nginx['listen_addresses'] = ["172.0.0.1", "[::1]"] # Ecoute seulement locale
```

#### le paramétre ```listen_port```:

```ruby
# si on ne passe par un proxy :
nginx['listen_port'] = 8081
```
> Note : ici le port 8080 est utilisé par le serveur Unicorn de Gitlab , On mettra donc le port 8081 pour éviter les surprises !!

#### le paramétre ```listen_https``` :

```ruby
# Pas besoin de HTTPS car on passe par le proxy
nginx['listen_https'] = false
```
> Note : Pas besoin de paramétrer le port HTTPS car on reste ici en local, on le mettra en place via notre proxy.

## Paramétrage du proxy :

> Note : Ici on va utiliser un proxy Nginx mais il est tout a fait possible d'utiliser Apache a la palce.
> Rappel :
> On souhaite obtenir un schéma de ce genre : 
> ```
> mondomaine.com : Site web
> |---> modomaine.com/gitlab : Gitlab
> |---> monodmaine.com/ldap : phpldapadmin
> +---> etc...
> ```

Pour se faire :

```nginx
#VHOST for http 2 https redirect
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	server_name www.passbolt.local;
	return 301 https://$host$request_uri;
}
#HTTPS Vhost
server {
	listen 443 ssl default_server;
	listen [::]:443 ssl default_server;
	 
	ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

	root /var/www/html/;
	server_name www.passbolt.local;
	log_not_found on;
#GITLAB
	location /gitlab {
		 proxy_pass http://localhost:8081;
		 proxy_redirect off;
 		proxy_set_header Host $http_host;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_set_header X-Forwarded-Proto $scheme;
 		proxy_set_header X-Forwarded-Protocol $scheme;
 		proxy_set_header X-Url-Scheme $scheme;
	}
}

```
> Remarque : Ici on redirige automatiquement vers du HTTPS 