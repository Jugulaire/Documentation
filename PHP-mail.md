# Pear PHP Mail 

## Installation de Pear :

```bash
wget https://pear.php.net/go-pear.phar

php go-pear.phar

# Appuyer sur entrée
```
## Installation de Mail :

```bash
pear install --alldeps Mail
```
## Parametrage de Pear dans PHP :

Dans ``/etc/php5/cli/php.ini `` :

Decommenter la ligne : 
(ligne 709)
```php
;;;;;;;;;;;;;;;;;;;;;;;;;
; Paths and Directories ;
;;;;;;;;;;;;;;;;;;;;;;;;;

; UNIX: "/path1:/path2"
include_path = ".:/usr/share/php"
;
```
On relance php-fpm :

```bash
service php5-fpm restart
```

## Programme de test :

```php

<?php
// Pear Mail Library
require_once "Mail.php";

$from = 'blabla@blublu.com';
$to = 'Unemail@undomaine.com';
$subject = 'Test';
$body = "Coucou,\n\nCeci est un test";

$headers = array(
    'From' => $from,
    'To' => $to,
    'Subject' => $subject
);

$smtp = Mail::factory('smtp', array(
        'host' => 'smtp.blabla.com',
        'port' => '587',
        'auth' => true,
        'username' => 'blabla@gmail.com',
        'password' => 'password'
    ));

$mail = $smtp->send($to, $headers, $body);

if (PEAR::isError($mail)) {
	echo('<p>' . $mail->getMessage() . '</p>');
} else {
	echo('<p>Message successfully sent!</p>');
}

?>


```