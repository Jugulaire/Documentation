# Parametrage mail de Gitlab :

On va ici paramètrer un serveur mail pour envoyer les notifications et les invitations aux utilisateurs spécifié dans notre annuaire LDAP.

Pour se faire on utiliseras Gmail avec un compte spécialement créé a cet effet.

La documentation de gitlab detail beaucoup de mail providers. 
[Lien](https://docs.gitlab.com/omnibus/settings/smtp.html

```ruby
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "bob.paterson@gmail.com"
gitlab_rails['smtp_password'] = "bobisawesome"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['smtp_openssl_verify_mode'] = 'peer' # Can be: 'none', 'peer', 'client_once', 'fail_if_no_peer_cert', see http://api.rubyonrails.org/classes/ActionMailer/Base.html
```
On va maintenant tester la configuration :

```bash
gitlab-rails console 
irb(main):01:0> Notify.test_mail('dest_email','Sujet du message', 'Corp du message').deliver_now
```
