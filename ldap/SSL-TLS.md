# Installation de OpenLDAP avec STARTTLS :

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

```haskell
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

### [0x210] Installation de openLDAP :

```bash
    sudo apt-get update
    sudo apt-get install slapd ldap-utils
```
On va ici vous demander un mot de passe, mais comme nous allons le reconfigurer juste aprés laissez le vide.

### [0x220] Paramétrage de base de OpenLDAP :

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

### [0x230] Installation de GnuTLS :

Ces outils nous servirons a crée nos certificats. 

```bash
sudo apt-get install gnutls-bin ssl-cert
```
## [0x300] Création de certificats auto signé :

Pour sécurisé nos connexion nous devons créee des certificats autosigné 

### [0x310] Création de templates :

#### [0x311] Le pour le CA

```bash
sudo mkdir /etc/ssl/templates
sudo vi /etc/ssl/templates/ca_server.conf
```

Nous allons ici spécifier quelques informations trés basiques :

```haskell
cn = LDAP Server CA
ca
cert_signing_key
```
#### [0x312] Pour le service LDAP :

```bash
/etc/ssl/templates/ldap_server.conf
```
Puis on renseigne ses informations :
```haskell
organization = "nom-organisation"
cn = ldap.example.com
tls_www_server
encryption_key
signing_key
expiration_days = 3652
```
### [0x320] Création de certificats :

#### [0x321] Création de la clé du CA :

Géneration de la clé privé du CA :

```bash
certtool -p --outfile /etc/ssl/private/ca_server.key
```
Génération du certificat de la CA (a partir de la clé crée juste avant) :

```bash
certtool -s --load-privkey /etc/ssl/private/ca_server.key --template /etc/ssl/templates/ca_server.conf --outfile /etc/ssl/certs/ca_server.pem
```
#### [0x322] Création de la clé pour le service ldap :

Ici, on génére la clé privée du serveur LDAP :

```bash
certtool -c --load-privkey /etc/ssl/private/ldap_server.key --load-ca-certificate /etc/ssl/certs/ca_server.pem --load-ca-privkey /etc/ssl/private/ca_server.key --template /etc/ssl/templates/ldap_server.conf --outfile /etc/ssl/certs/ldap_server.pem
```

> Note : Les clé sont maintenant toutes generé passons a la suite :

## [0x400] Mise en place des certificats :

### [0x410] permettre a openLDAP l'acces a la clé du serveur :

```bash
usermod -aG ssl-cert openldap
chown :ssl-cert /etc/ssl/private/ldap_server.key
chmod 640 /etc/ssl/private/ldap_server.key
```
### [0x420] Configuration de openLDAP 

On va crée un fichier ldif car on ne peux pas moddifier la configuration de openLDAP autrement.

```bash
cd ~
vi certs.ldif
```
Voici le contenu du fichier :

```haskell
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ssl/certs/ca_server.pem
-
add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ssl/certs/ldap_server.pem
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ssl/private/ldap_server.key
```
> Note : ici on utilise le mot clé **add** mais si vous devez modifier les parametres mettez **replace** car openLDAP fait le distingo entre ajout et modification.

On va maintenant utiliser ldapmodify pour appliquer nos paramétres :

```bash
ldapmodify -H ldapi:// -Y EXTERNAL -f certs.ldif
```
Puis on re charge la configuration du serveur pour la rendre éfféctive :

```bash
service slapd force-reload
```

## [0x500] Parametrage des clients :

### [0x510] Sur le serveur :

Dans un premiers temps on copie le fichier ``/etc/ssl/certs`` vers ``/etc/ldap``. Nous allons le nommé **ca_certs.pem** car il pourras eventuellement contenir plusieurs certificats de CA.

```bash
cp /etc/ssl/certs/ca_server.pem /etc/ldap/ca_certs.pem
```
On va maintennat éditer les paramétres pour que ldap-utils fonctionne :

```bash
vi /etc/ldap/ldap.conf
```
On va modifier la ligne ** TLS_CACERT ** :

```haskell
TLS_CACERT /etc/ldap/ca_certs.pem
```
On va maintenant tester tout ça :

```bash
ldapwhoami -H ldap:// -x -ZZ

```
Resultat attendus : 

```haskell
anonymous
```
Si un parametre est érroné une erreur du genre devrais apparaitre : 
(vérifiez simplement la configuration pour corriger le probleme).
```haskell
STARTTLS failure

ldap_start_tls: Connect error (-11)
    additional info: (unknown error code)

```
### [0x520] Sur les client distant :

Pour les clients distants il nous faut le certificat de la CA crée précédement. Pour se faire on va utiliser SCP :
```bash
client$ cat ~/ca_server.pem | sudo tee -a /etc/ldap/ca_certs.pem
```
On va ensuite modifier les parametres pour faire reconnaitre notre CA par ldap :

```bash
vi /etc/ldap/ldap.conf
```
On va modifier la ligne ** TLS_CACERT ** :

```haskell
TLS_CACERT /etc/ldap/ca_certs.pem
```
On test a nouveau avec 
```bash
ldapwhoami -H ldap://mon.serveur.com -x -ZZ
```
Résultat esperé : 

```haskell
anonymous
```