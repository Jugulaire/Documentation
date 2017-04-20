# -*- coding: utf-8 -*-
# Description: exim netdata python.d module
# Author: Pawel Krupa (paulfantom)

from base import ExecutableService
import subprocess
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
