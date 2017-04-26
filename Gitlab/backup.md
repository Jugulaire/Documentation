# Gitlab backup & restore 

## I - Crée une backup 

> NOTE : le gitlab sur lequel vous allez restaurer la backup doit avoir même version que celui depuis lequel vous la crée.

Depuis un serveur local :

```bash
sudo gitlab-rake gitlab:backup:create
```

Depuis un container Docker (sameersbn/gitlab:9.1.0-1):
```bash
docker stop gitlab && docker rm gitlab

docker run --name gitlab -d     --link gitlab-postgresql:postgresql --link gitlab-redis:redisio     --publish 10022:22 --publish 10080:80 --publish 10443:443     --env 'SMTP_USER=google@jukeback.com' --env 'SMTP_PASS=Nancy!Jukeback'     --env 'SMTP_HOST=mail.gandi.net'     --env 'SMTP_DOMAIN=jukeback.com'      --env 'SMTP_AUTHENTICATION=plain'     --env 'GITLAB_PORT=10080' --env 'GITLAB_SSH_PORT=10022'     --env 'GITLAB_SECRETS_DB_KEY_BASE=pxchJsJTXNHpkPvmkMXLvNHjqRTWbrP4MvnV3ppdCLRPWJMCFMcz9fr4WLkfmknh' --env 'GITLAB_SECRETS_OTP_KEY_BASE=s3jvp3LfTHzQSnXhlkRGFQTXzSkZkcGPJWLvp9qn2T9S5ln3cGRtlrW3J4PLWLXG' --env 'GITLAB_SECRETS_SECRET_KEY_BASE=s3jvp3LfTHzQSnXhlkRGFQTXzSkZkcGPJWLvp9qn2T9S5ln3cGRtlrW3J4PLWLXG'   --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_PORT=10443'     --env 'GITLAB_HTTPS=true' --env 'GITLAB_HOST=163.172.155.163' --env 'SSL_SELF_SIGNED=true' \--volume /srv/docker/gitlab/gitlab:/home/git/data     sameersbn/gitlab:9.1.0-1 app:rake gitlab:backup:create

```
## II - Récupérer la backup :

1. Dans le cas d'un serveur local elle se trouve dans ``/var/opt/gitlab/backups/``

2. Dans le cas du conteneur Docker elle se situe où vous l'avez mise. Pour savoir où elle se trouve il suffit de regarder l'option ``--volume`` de la commande docker run (ci-dessus) et on vois que nos backups sont dans ``/srv/docker/gitlab/backups/ ``

Dans notre cas on pourra utiliser scp pour récupérer cette sauvegarde : 
```bash
scp user@IP_ancien_srv:/srv/docker/gitlab/gitlab/backups/1493196544_2017_04_26_gitlab_backup.tar /home/jugu/
```

## III - Restauration de la backup :

On copie l'archive .tar que l'on a récupéré sur notre ancien serveur sur le nouveau dans ``/var/opt/gitlab/backups/`` puis on lance la commande suivante :
> Note : cette archive a un nom au format : ``1493196544_2017_04_26_gitlab_backup.tar``
> La première partie correspond a un timestamp qu'il faut ajouter a ``BACKUP=``

```bash
#on stop le serveur
sudo gitlab-ctl stop unicorn
sudo gitlab-ctl stop sidekiq
#on vérifie qu'il est bien off
sudo gitlab-ctl status
#On restaure
gitlab-rake gitlab:backup:restore BACKUP=1493196544_2017_04_26
```
On vérifie ensuite que tout va bien : 

```bash
#On relance notre serveur 
sudo gitlab-ctl start
#On lance le check
sudo gitlab-rake gitlab:check SANITIZE=true
```
Si des problèmes de droit surviennent sur le dossier upload :
```bash
sudo chmod 700 -R /var/opt/gitlab/gitlab-rails/uploads/
```