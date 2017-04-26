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