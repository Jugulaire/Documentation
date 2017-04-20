# Setup de LDAP + PHPldapadmin

Cette installation se déroule en deux grandes étapes :

1. Installation de OpenLDAP
2. Installation de PHPLDAPadmin

## Installation de OpenLDAP :

Via les dépots Debian/Ubuntu :

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
3. Nom d'entité (« organization ») : ** nom choisis pour la racine** 
4. Mot de passe (user) : **On met celui que l'on a choisis plus tôt**
5. Mot de passe administratuer : **Même chose**
6. Module de base de données à utiliser : **HDB**
7. Faut-il supprimer la base de données lors de la purge du paquet ? : **NON**
8. Faut-il déplacer l'ancienne base de données ? : **OUI**
9. Faut-il autoriser le protocole LDAPv2 ? : **NON (pas sécurisé)**

## Installation de PHPLDAPadmin : 
