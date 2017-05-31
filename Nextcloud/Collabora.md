# Installation de collbora :

## Image Docker :

```bash
docker pull collabora/code
docker run -t -d -p 127.0.0.1:9980:9980 -e "domain=<your-dot-escaped-domain>" -e "username=admin" -e "password=S3cRet" --restart always --cap-add MKNOD collabora/code
```

``<your-dot-escaped-domain>`` Est le domaine sur lequelle est hebergé l' instance de nextcloud qui va utiliser collabora.
``username`` et ``password`` activent une console admin a l'adresse suivante :``https://<CODE-domain>/loleaflet/dist/admin/admin.html``

>Note : Si besoin, on peut éditer les paramétres dans le conteneur avec la commande suivante : ``docker exec -it --user root <conteneur-name> bash`` On editera ensuite le fichier ``/etc/loolwsd/loolwsd.xml``.



## Configuration Nginx 

>Note: Prenez bien cette configuration car celle du site officiel de collabora **NE MARCHE PAS**.

```nginx
#---------------------------------------------------------------------------------------------
# Collabora
#---------------------------------------------------------------------------------------------

# static files
    location ^~ /loleaflet {
        proxy_pass https://localhost:9980;
        proxy_set_header Host $http_host;
    }

    # WOPI discovery URL
    location ^~ /hosting/discovery {
        proxy_pass https://localhost:9980;
        proxy_set_header Host $http_host;
    }

    # Main websocket
    location ~ /lool/(.*)/ws$ {
        proxy_pass https://localhost:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }

    # Admin Console websocket
    location ^~ /lool/adminws {
        proxy_pass https://localhost:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }

    # download, presentation and image upload
    location ^~ /lool {
        proxy_pass https://localhost:9980;
		proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
		proxy_read_timeout 36000s;
    }

```
## Configuration de nextcloud :

En tant qu'administrateur :
On se rend dans l'onglet ``Nextcloud`` (en haut a gauche)
On sélectionne ``apps``
On sélectionne à gauche la catégorie ``office & text``
On installe collabora

On se rend ensuite dans ``admin`` (en haut a droite)
On A gauche doit apparaitre un lien ``Collabora Online``
On va simplement indiquer l'adresse du serveur ou se trouve notre instance Collabora. 