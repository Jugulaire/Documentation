# Installation de Nextcloud

## [0x100] Pré-requis 

> Note : On peut vérifier que les dépendnaces sont installé avec **php -m | grep -i module_name**

Voici la liste des dépendnaces PHP : 
- php5 (>= 5.4)
- PHP module ctype
- PHP module dom
- PHP module GD
- PHP module iconv
- PHP module JSON
- PHP module libxml (Linux package libxml2 must be >=2.7.0)
- PHP module mb multibyte
- PHP module posix
- PHP module SimpleXML
- PHP module XMLWriter
- PHP module zip
- PHP module zlib
- PHP Mysql

## [0x200] Installation
> Note : On part de principe que l'on a déja installer Nginx avec php5-fpm.

### [0x210] Mysql
On crée le classique utilisateur et la base de données pour Nextcloud :

```bash
sudo mysql -h localhost -p
```
```sql
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'Strong_Password';
CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON nextcloud. * TO 'nextcloud'@'localhost';
```

### [0x220] Nextcloud

On télécharge et décompresse Nextcloud dans **/var/www/html/nextcloud** 

```bash
cd /tmp
wget https://download.nextcloud.com/server/releases/nextcloud-11.0.3.zip 
unzip nextcloud-11.0.3.zip -d /Var/www/html/
```
### [0x230] Nginx

``` nginx
#NEXTCLOUD
        location ^~ /nextcloud {
                alias /var/www/html;
        		client_max_body_size 512M;
        		fastcgi_buffers 64 4K;
        		gzip off;
        		error_page 403 /nextcloud/core/templates/403.php;
        		error_page 404 /nextcloud/core/templates/404.php;

        		location /nextcloud {
                        alias /var/www/html;
            			rewrite ^ /nextcloud/index.php$uri;
        		}
        		location ~ ^/nextcloud/(?:build|tests|config|lib|3rdparty|templates|data)/ {
            		deny all;
        		}
        		location ~ ^/nextcloud/(?:\.|autotest|occ|issue|indie|db_|console) {
            		deny all;
        		}

        		location ~ ^/nextcloud/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+|core/templates/40[34])\.php(?:$|/) {
                    alias /var/www/html;
            		include fastcgi_params;
            		fastcgi_split_path_info ^(.+\.php)(/.*)$;
            		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
					fastcgi_param PATH_INFO $fastcgi_path_info;
            		fastcgi_param HTTPS on;
            		fastcgi_param modHeadersAvailable true;
            		fastcgi_param front_controller_active true;
            		fastcgi_pass unix:/var/run/php5-fpm.sock;
            		fastcgi_intercept_errors on;
        		}

        		location ~ ^/nextcloud/(?:updater|ocs-provider)(?:$|/) {
                    alias /var/www/html;
            		try_files $uri/ =404;
            		index index.php;
        		}
 				location ~* \.(?:css|js)$ {
                    alias /var/www/html;
            		try_files $uri /nextcloud/index.php$uri$is_args$args;
            		add_header Cache-Control "public, max-age=7200";
            		add_header X-Content-Type-Options nosniff;
            		add_header X-Frame-Options "SAMEORIGIN";
            		add_header X-XSS-Protection "1; mode=block";
            		add_header X-Robots-Tag none;
            		add_header X-Download-Options noopen;
            		add_header X-Permitted-Cross-Domain-Policies none;
            		access_log off;
        		}

        		location ~* \.(?:svg|gif|png|html|ttf|woff|ico|jpg|jpeg)$ {
                    alias /var/www/html;
            		try_files $uri /nextcloud/index.php$uri$is_args$args;
            		access_log off;
        		}
    }

```
### [0x240] Parametrages 

Rendez vous a l'adresse **domaine.tld/nextcloud** pour débuter le paramétrage de Nextcloud.
