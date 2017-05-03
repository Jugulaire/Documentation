# Configuration de LDAP avec gitlab

Etapes : 

1. Création d'un utilisateur LDAP spécifique
2. Paramétrage de gitlab
3. Test de la configuration 
4. Reconfiguration

## I - Création de l'utilisateur :

Avec phpLDAPadmin :

1. On se connecte en tant qu'administrateur
2. On crée un groupe que l'on nomme "noperm"
3. On crée un utilisateur "gitlab" dans ce groupe

## II - Paramétrage de gitlab :

Dans ```/etc/gitlab/gitlab.rb``` :

```ruby
 gitlab_rails['ldap_enabled'] = true
 gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
 
 main: 
  label: 'LDAP'
  #IP/domaine du serveur LDAP
  host: '127.0.0.1' 
  #Port par défaut
  port: 389 
  #Compatibilité avec openLDAP
  uid: 'uid' 
  method: 'plain'
   #distinguished name de l'utilisateur créé précédement
  bind_dn: 'cn=gitlab,dc=nodomain'
  #Password de l'utilisateur
  password: 'toto'
  active_directory: true
  allow_username_or_email_login: false
  block_auto_created_users: false
  #distinguished name du point d'entrée dans l'annuaire 
  base: 'CN=test,OU=groups,DC=nodomain'
  #Ne prendre que les personnes avec le role developpeur
  user_filter: '(employeeType=developper)'
 EOS
```
## III - Test de configuration :

En ligne de commande on va s'assurer que nos paramètres sont corrects et que des utilisateurs sont bel et bien retournés par le serveur LDAP :

```bash
ldapsearch -H ldaps://$host:$port -D "$bind_dn" -y bind_dn_password.txt  -b "$base" "$user_filter" $uid
```
les valeur precédées par un $ sont les variables de notre fichier de configuration. 
Par exemple : 
```bash
ldapsearch -H ldap://127.0.0.1:389 -D "cn=gitlab,dc=nodomain" -W  -b "dc=nodomain" "(employeeType=developper)" uid
```
Ce qui me retourne :
```bash
# extended LDIF
#
# LDAPv3
# base <dc=nodomain> with scope subtree
# filter: (employeeType=developper)
# requesting: uid 
#

# bob paterson, test, groups, nodomain
dn: cn=bob paterson,cn=test,ou=groups,dc=nodomain
uid: bpaterson

# jugu laire, test, groups, nodomain
dn: cn=jugu laire,cn=test,ou=groups,dc=nodomain
uid: jlaire

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
```
## IV - Reconfiguration :

On va maintenant reconfigurer gitlab pour qu'il prenne en compte les paramètres saisis plus haut :
```bash
gitlab-ctl reconfigure
```
Puis on vérifie à nouveau que tout va bien avec :

```bash
gitlab-rake gitlab:ldap:check
```
Vous devriez avoir un résultat de ce genre :

```bash
Checking LDAP ...

Server: ldapmain
LDAP authentication... Success
LDAP users with access to your GitLab server (only showing the first 100 results)
	DN: cn=bob paterson,cn=test,ou=groups,dc=nodomain	 uid: bpaterson
	DN: cn=jugu laire,cn=test,ou=groups,dc=nodomain	 uid: jlaire

Checking LDAP ... Finished
```

## V - Les filtres :

On arrive donc a se connecter sur gitlab avec LDAP mais encore faut-il pouvoir reguler l'acces a ce derniers.

Pour se faire on va mettre en place une filtre.

Dans notre cas on va simplement assigner une ou (Organisational unit) a nos utilisateur.

Un utilisateur aillant le droit de se connecter sur gitlab auras donc ou=gitlab dans ses attributs.

Pour mettre en place ce filtre on edite ``user_filter`` dans la configuration LDAP montrée plus haut. 
```ruby
 user_filter: '(ou=gitlab)'
```
On lance ensuite ``gitlab-ctl reconfigure``

On peut eventuellement tester a nouveau avec ``gitlab-rake gitlab:ldap:check``.