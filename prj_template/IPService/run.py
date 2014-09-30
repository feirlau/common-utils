#!/user/bin/env python
#encoding=utf-8

from django.core.management.commands import runserver

try:
    import sys
    import os
    from IPServicePython import settings # Assumed to be in the same directory.
    
    os.environ[ 'DJANGO_SETTINGS_MODULE' ] = "IPServicePython.settings"
    os.system("cls")
    print "Server started, [ctrl]+[c] to exist!"
    sys.stdout = open(settings.LOG_FILE_OUT, "w")
    sys.stderr = open(settings.LOG_FILE_ERR, "w")
except ImportError:
    sys.stderr.write("Error: Can't find the file 'settings.py' in the directory containing %r. It appears you've customized things.\nYou'll have to run django-admin.py, passing it your settings module.\n(If the file settings.py does indeed exist, it's causing an ImportError somehow.)\n" % __file__)
    sys.exit(1)

if __name__ == "__main__":
    cmd = runserver.Command()
    cmd.run_from_argv(["run.py", "runserver", "0.0.0.0:8808"])