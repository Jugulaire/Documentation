# Installation de OpenLDAP avec STARTTLS 

> Note : Plutôt que de séparer le port LDAPS du port LDAP classique nous allons ici utiliser STARTLS pour que le port 389 puisse recevoir les deux types de requetes.
> Note2 : LDAPS est deprecier.

## [0x100] Hostname et FQDN :

Dans un prmeier temps nous allons nous assurer que notre serveur est capable se résoudre son hostname ainsi que son FQDN.
> Note: Dans l'exemple nous allons partir du principe que le FQDN est ldap.example.com

Pour se faire nous allons utiliser hostnamectl :

```bash
sudo hostnamectl set-hostname ldap
```

> Note: Ici on spécifie le short hostname (sans le nom de domaine)
On édite ensuite le FQDN dans /etc/hosts :

```
sudo nano /etc/hosts

# Contenue du fichier

127.0.1.1 ldap.example.com ldap
127.0.0.1 localhost

```
On test : 

```bash
hostname # Affiche le short hostname

ldap

hostname --fqdn # Affiche le FQDN

ldap.example.com
```

## [0x200] Installation de OpenLDAP et de GnuTLS :

### [0x210] Installation de openLDAP

```bash
    sudo apt-get update
    sudo apt-get install slapd ldap-utils
```
On va ici vous demander un mot de passe, mais comme nous allons le reconfigurer juste aprés laissez le vide.

### [0x220] Paramétrage de base de OpenLDAP 

```bash 
sudo dpkg-reconfigure slapd
```
Un éditeur semi graphique apparait :

1. Voulez-vous omettre la configuration d'OpenLDAP ? : NON
2. Nom de domaine : ** On met son nom de domaine**
3. Nom d'entité (« organization ») : ** nom choisi pour la racine**
4. Mot de passe (user) : On met celui que l'on a choisi plus tôt
5. Mot de passe administrateur : Même chose
6. Module de base de données à utiliser : HDB
7. Faut-il supprimer la base de données lors de la purge du paquet ? : NON
8. Faut-il déplacer l'ancienne base de données ? : OUI
9. Faut-il autoriser le protocole LDAPv2 ? : NON (pas sécurisé)
