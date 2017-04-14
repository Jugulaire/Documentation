# Postgres dans Docker

> On souhaite crée un volume commun entre le conteneur et notre machine hôte pour avoir une persistance des données de la BDD.

- On va donc modifier le fichier Docker-compose
```haskell 
vi myapp/src/main/docker/postgres.yml
```
- On remplace :
```haskell
volumes:
  - ./postgres-data:/var/lib/postgresql
```
- par:
```haskell
volumes:
  - ./postgres-data:/var/lib/postgresql/data
```
- On va ensuite supprimer tous les fichiers précédement créés par les volumes Docker pour éviter des conflits d' authorisations.
```haskell
rm -rf postgres-data  
```
- On relance ensuite notre Docker-compose 
```haskell
docker-compose -f myapplication/src/main/docker/app.yml up -d --force-recreate
```
On devrait retrouver nos fichiers :
```haskell
parrot# ls postgresql 
base	      pg_dynshmem    pg_multixact  pg_snapshots  pg_tblspc    postgresql.auto.conf
global	      pg_hba.conf    pg_notify	   pg_stat	 pg_twophase  postgresql.conf
pg_clog       pg_ident.conf  pg_replslot   pg_stat_tmp	 PG_VERSION   postmaster.opts
pg_commit_ts  pg_logical     pg_serial	   pg_subtrans	 pg_xlog      postmaster.pid
```