#
# A sample service to be 'compiled' into an exe-file with py2exe.
#
# See also
#    setup.py - the distutils' setup script
#    setup.cfg - the distutils' config file for this
#    README.txt - detailed usage notes
#
# A minimal service, doing nothing else than
#    - write 'start' and 'stop' entries into the NT event log
#    - when started, waits to be stopped again.
#
import win32serviceutil
import win32service
import win32event
import win32api
import win32con
import subprocess
import imp, os, sys
from dict4ini import dict4ini
import time

# get main directory, from http://www.py2exe.org/index.cgi/HowToDetermineIfRunningFromExe  
def main_is_frozen():
    return (hasattr(sys, "frozen") or # new py2exe
            hasattr(sys, "importers") or # old py2exe
            imp.is_frozen("__main__")) # tools/freeze
def get_main_dir():
    tmp_dir = "."
    if main_is_frozen():
        tmp_dir = os.path.dirname(sys.executable)
    else:
        tmp_dir = os.path.dirname(__file__)
    return tmp_dir

CURRENT_DIR = get_main_dir()
SVC_CONFIG_PATH = os.path.join(CURRENT_DIR, "data/service_config.ini")
DEFAULT_SERVICE_LOG_FILE = os.path.join(CURRENT_DIR, "data/service_log.txt")
log_hander = None

try:
    log_hander = open(DEFAULT_SERVICE_LOG_FILE, 'a+')
except Exception, msg:
    print msg

log_time_format = "%Y-%m-%d %H:%M:%S"
def log(level, info):
    try:
        tmp_info = time.strftime(log_time_format, time.localtime())
        tmp_info = tmp_info + " [" + level + "] " + info + "\n"
        log_hander.write(tmp_info)
        log_hander.flush()
    except Exception, msg:
        print msg

class MyPyService(win32serviceutil.ServiceFramework):
    _svc_conf_ = dict4ini.DictIni(SVC_CONFIG_PATH)
    _svc_name_ = str(_svc_conf_.MyPyService.name)
    _svc_display_name_ = str(_svc_conf_.MyPyService.displayName)
    _svc_description_ = str(_svc_conf_.MyPyService.description)
    
    _svc_cwd_ = None
    if(_svc_conf_.MyPyService.has_key("cwd")):
        _svc_cwd_ = _svc_conf_.MyPyService.cwd
    if(_svc_cwd_==None or _svc_cwd_.strip()==""):
        _svc_cwd_ = CURRENT_DIR
    elif(not os.path.isabs(_svc_cwd_)):
        _svc_cwd_ = os.path.join(CURRENT_DIR, _svc_cmd_)
    _svc_command_ = str(_svc_conf_.MyPyService.command)
    _svc_parameters_ = None
    if(_svc_conf_.MyPyService.has_key("parameters")):
        _svc_parameters_ = _svc_conf_.MyPyService.parameters
    _svc_process_ = None
    _svc_stdout_ = log_hander
    
    def __init__(self, args):
        log("info", "System service init...")
        win32serviceutil.ServiceFramework.__init__(self, args)
        self.hWaitStop = win32event.CreateEvent(None, 0, 0, None)

    def SvcStop(self):
        log("info", "System service stop...")
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        win32event.SetEvent(self.hWaitStop)

    def SvcDoRun(self):
        try:
            tmp_command = '"' + self._svc_command_ + '" ' + self._svc_parameters_
            log("info", os.environ)
            log("info", "System service start, command: " + tmp_command + ", cwd: " + self._svc_cwd_)
            self._svc_process_ = subprocess.Popen(tmp_command, cwd=self._svc_cwd_, shell=False, bufsize=-1, stdin=subprocess.PIPE, stdout=self._svc_stdout_, stderr=subprocess.STDOUT)
            log("info", "System service started, command: " + tmp_command)
            # wait for beeing stopped...
            win32event.WaitForSingleObject(self.hWaitStop, win32event.INFINITE)
            handle = win32api.OpenProcess(win32con.PROCESS_TERMINATE, 0, self._svc_process_.pid)
            win32api.TerminateProcess(handle, 0)
            win32api.CloseHandle(handle)
            self._svc_process_ = None
            log("info", "System service stopped, command: " + tmp_command)
        except Exception, msg:
            log("error", "System service start failed: " + str(msg))

if __name__ == '__main__':
    # Note that this code will not be run in the 'frozen' exe-file!!!
    win32serviceutil.HandleCommandLine(MyPyService)
