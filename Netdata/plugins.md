# Création de plugins personnalisé :

> Avec netdata on peut créer nos propres plugins pour monitorer tout et n'importe quoi.

Dans cet exemple nous allons créé un plugin pour monitorer la température de mon Odroid U3.

Voici les étapes :

1. Création d'un script retournant les valeurs a mesuré
2. Création d'un plugin en python pour Netdata
3. Test du plugin
4. Déploiement de ce dernier

## Création d'un script de récupération des valeurs :

Dans un premier temps on va écrire un petit script bash qui va nous retourner les valeurs suivantes :
- température CPU
- valeur PWM actuelle du ventilateur
- température de lancement du ventilateur
- température d'alerte du CPU
- température critique du CPU

> Note : On aurait pu écrire un programme en C ou en n'importe quoi d'autre pour réaliser ces opérations.

Voici donc le script en question :

```bash
#!/bin/bash


temp=$(expr $(cat /sys/devices/virtual/thermal/thermal_zone0/temp) / 1000)
pwm=$(cat /sys/devices/platform/odroidu2-fan/pwm_duty | sed 's/.* : .* -> //g' | sed -e 's/.(.*).//g')
start_temp=$(cat /sys/devices/platform/odroidu2-fan/start_temp | sed 's/.* : .* -> //g' | sed -e 's/.(.*)//g')	
warn=$(expr $(cat /sys/devices/virtual/thermal/thermal_zone0/trip_point_0_temp) / 1000)	
critical=$(expr $(cat /sys/devices/virtual/thermal/thermal_zone0/trip_point_2_temp) / 1000)

printf "%d\n%s\n%s\n%d\n%d\n" "$temp" "$pwm" "$start_temp" "$warn" "$critical"
```
On le lance : 

```bash
# on rend le script éxécutable
jugu@odroid-jessie:~$ chmod +x cpu.sh
# on l'éxécute
jugu@odroid-jessie:~$ ./cpu.sh
43 
0
50 
85
110
```
> Note : Il est important que vous obteniez un résultat similaire sur vos scripts car sinon la suite ne va pas fonctionner !

## Création d'un plugin 

On va partir de ce squelette de plugin :

```python

from base import ExecutableService

# Configuration de base du plugin 
# update_every = 2
priority = 60000
retries = 60

# definition et ordre des graphiques
ORDER = ['graph1','graph2']

CHARTS = {
    'graph1': {
        'options': [None, "Exim Queue Emails", "emails", 'queue', 'exim.qemails', 'line'],
        'lines': [
            ['line1', None, 'absolute'],
			['line2', None, 'absolute']
        ]},
	'graph2': {
        'options': [None, "Exim Queue Emails", "emails", 'queue', 'exim.qemails', 'line'],
        'lines': [
            ['emails', None, 'absolute']
        ]}
}


class Service(ExecutableService):
    def __init__(self, configuration=None, name=None):
        ExecutableService.__init__(self, configuration=configuration, name=name)
        self.command = "Commande-a-Executé"
        self.order = ORDER
        self.definitions = CHARTS

    def _get_data(self):

        try:
            return {
			'emails': int(self._get_raw_data()[0]),
			'line1': int(self._get_raw_data()[1]),
			'line2': int(self._get_raw_data()[2])
			}
        except (ValueError, AttributeError):
            return None

```
> Note : une fois la commande exécutée on récupère un tableau contenant dans chacune de ses cases les valeurs retournées de notre script. C'est pour cette raison qu'il nous faut obtenir le même pattern que celui montré au-dessus.

On va donc maintenant écrire notre plugin personnalisé :

```python

from base import ExecutableService
# default module values (can be overridden per job in `config`)
update_every =5
priority = 60000
retries = 60

# charts order (can be overridden if you want less charts, or different order)
ORDER = ['Temp']

CHARTS = {
    'Temp': {
        'options': [None, "Current CPU status", "celsius", 'CPU', 'cpu.Temp', 'line'],
        'lines': [
            ['Temp', None, 'absolute'],
            ['start-temp', None, 'absolute'],
            ['warn', None, 'absolute'],
            ['crit', None, 'absolute']
        ]}
}


class Service(ExecutableService):
    def __init__(self, configuration=None, name=None):
        ExecutableService.__init__(self, configuration=configuration, name=name)
        self.command = "/home/jugu/cpu.sh"
        self.order = ORDER
        self.definitions = CHARTS
    def _get_data(self):

        try:
            return {'Temp': int(self._get_raw_data()[0]),
                    'start-temp' : int(self._get_raw_data()[2]),
                    'warn' : int(self._get_raw_data()[3]),
                    'crit' : int(self._get_raw_data()[4])
}
        except (ValueError, AttributeError):
            return None

```

Comme on le voit en lisant ce code, la méthode **_get_data()** récupére chaque ligne retournée par mon script bash et la met à l'intérieur d'un tableau. Puis enfin j'assigne chacune des valeurs de ce tableau à un courbe de graphique.

Ce plugin doit être enregistré en respectant un nommage précis :

```haskell
NOM-PLUGIN.chart.py 
```

Ce dernier doit être situé dans ``/usr/libexec/python.d/``

## Test du plugin :

On va tester notre plugin en tant que l'utilisateur Netdata (c'est lui qui l'exécutera en production).

```bash
sudo su -s /bin/bash netdata

### On teste

/usr/libexec/netdata/plugins.d/python.d.plugin 1 debug Mon-plugin
```
Si tout se passe bien vous devriez obtenir des valeurs et sinon divers informations vous sont fournies pour vous aider à corriger tout ça.

## Déploiement du plugin

On va simplement relancer netdata :

```bash
service netdata restart
```

