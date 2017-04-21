# Setup de LDAP + PHPldapadmin

Cette installation se déroule en deux grandes étapes :

1. Installation de OpenLDAP
2. Installation de PHPLDAPadmin

## Installation de OpenLDAP :

Via les dépôts Debian/Ubuntu :

```bash
apt-get update && apt-get install slapd ldap-utils
```
> Un assistant semi-graphique va vous demander un mot de passe et un mot de passe admin **NOTEZ LES**

On passe a la reconfiguration de slapd :

```bash
dpkg-reconfigure slapd
```
Un éditeur semi graphique apparait :
1. Voulez-vous omettre la configuration d'OpenLDAP ? :  **NON**
2. Nom de domaine : ** On met son nom de domaine**
3. Nom d'entité (« organization ») : ** nom choisi pour la racine** 
4. Mot de passe (user) : **On met celui que l'on a choisi plus tôt**
5. Mot de passe administrateur : **Même chose**
6. Module de base de données à utiliser : **HDB**
7. Faut-il supprimer la base de données lors de la purge du paquet ? : **NON**
8. Faut-il déplacer l'ancienne base de données ? : **OUI**
9. Faut-il autoriser le protocole LDAPv2 ? : **NON (pas sécurisé)**

## Installation de PHPLDAPadmin : 

Via les dépots Debian :

```bash
apt-get install phpldapadmin
```
Ensuite on va modifier deux ou trois parametres :
Pour être bien certqins de ces derniers on va utiliser slapcat :
```haskell
➜  jugu slapcat              
dn: dc=nodomain
objectClass: top
objectClass: dcObject
objectClass: organization
o: nodomain
dc: nodomain
structuralObjectClass: organization
entryUUID: 733e5366-b9f9-1036-9516-bdbe2a12a29e
creatorsName: cn=admin,dc=nodomain
createTimestamp: 20170420094244Z
entryCSN: 20170420094244.883489Z#000000#000#000000
modifiersName: cn=admin,dc=nodomain
modifyTimestamp: 20170420094244Z

dn: cn=admin,dc=nodomain
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword:: e1NTSEF9YW5iTEVkcVlzYmw5ZGNQMkJ5bXY0Q3AxbS80WmlQKzE=
structuralObjectClass: organizationalRole
entryUUID: 735839ca-b9f9-1036-9517-bdbe2a12a29e
creatorsName: cn=admin,dc=nodomain
createTimestamp: 20170420094245Z
entryCSN: 20170420094245.053224Z#000000#000#000000
modifiersName: cn=admin,dc=nodomain
modifyTimestamp: 20170420094245Z
➜  jugu slapcat              
dn: dc=nodomain
objectClass: top
objectClass: dcObject
objectClass: organization
o: nodomain
dc: nodomain
structuralObjectClass: organization
entryUUID: 733e5366-b9f9-1036-9516-bdbe2a12a29e
creatorsName: cn=admin,dc=nodomain
createTimestamp: 20170420094244Z
entryCSN: 20170420094244.883489Z#000000#000#000000
modifiersName: cn=admin,dc=nodomain
modifyTimestamp: 20170420094244Z

dn: cn=admin,dc=nodomain
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword:: e1NTSEF9YW5iTEVkcVlzYmw5ZGNQMkJ5bXY0Q3AxbS80WmlQKzE=
structuralObjectClass: organizationalRole
entryUUID: 735839ca-b9f9-1036-9517-bdbe2a12a29e
creatorsName: cn=admin,dc=nodomain
createTimestamp: 20170420094245Z
entryCSN: 20170420094245.053224Z#000000#000#000000
modifiersName: cn=admin,dc=nodomain
modifyTimestamp: 20170420094245Z

```
Cette commande va nous fournir des informations primordiales sur la configuration que l'on a déja mise en place. 
éditons donc ces parametres :
``vi /etc/phpldapadmin/config.php``
```php
[1]
$servers->setValue('server','host','domain_name_or_IP_address');
[2]
$servers->setValue('server','base',array('dc=test,dc=com'));
[3]
$servers->setValue('login','bind_id','cn=admin,dc=test,dc=com');
[4]
$config->custom->appearance['hide_template_warning'] = true;
```
1. On remplace domain_name_or_IP_address par son nom de domaine ou son IP (dans le cadre de test laisser 127.0.0.1)
>NOTE : Ici on met en place le meme nom de domaine que celui fourni lors de la configuration de slapd !!!
2. Ici on ajoute notre domaine, par exemple si je suis dans le domaine ``wonderfull.example.com`` je vais mettre ``dc=wonderfull,dc=example,dc=com``
3. Ici on ajoute la meme chose que l'on a mis au dessus SANS TOUCHER A ``cn=admin`` ainsi avec le domaine ``wonderfull.example.com`` on a  ``cn=admin,dc=wonderfull,dc=example,dc=com``
4. On dit ici a phpldapadmin que l'on souhaite enlever les warning inutiles

##Troubleshooting :
1. Cas ou LDAP est en mode read-only :
On édite ``/etc/phpldapadmin/templates/creation/posixAccount.xml`` et on commente ``readonly``
```xml
<attribute id="uidNumber">
        <display>UID Number</display>
        <icon>terminal.png</icon>
        <order>6</order>
        <page>1</page>
<!--    <readonly>1</readonly> -->
        <value>=php.GetNextNumber(/;uidNumber)</value>
</attribute>
```

