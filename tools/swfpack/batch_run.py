import sys
import traceback
reload(sys)
sys.setdefaultencoding("utf-8")
import imp, os, codecs, fnmatch, subprocess, shutil, distutils.file_util

# the following two functions are from the py2exe wiki:
# http://www.py2exe.org/index.cgi/HowToDetermineIfRunningFromExe
def main_is_frozen():
    return (hasattr(sys, "frozen") or # new py2exe
            hasattr(sys, "importers") or # old py2exe
            imp.is_frozen("__main__")) # tools/freeze

# get main dir, for py2exe environment
def get_main_dir():
    tmp_dir = "."
    if main_is_frozen():
        tmp_dir = os.path.dirname(sys.executable)
    else:
        tmp_dir = os.path.dirname(__file__)
    return os.path.abspath(tmp_dir)

MAIN_DIR = get_main_dir()
DIR_NAME = os.path.split(MAIN_DIR)[1]
default_conf_dir = MAIN_DIR
default_log_file = os.path.join(MAIN_DIR, DIR_NAME + ".log")
default_out_file = os.path.join(MAIN_DIR, "out")
default_excludes = [".*"]
default_files = ["swfpack.py", "start.bat", "templete_animation.xml"]
default_exe = "start.bat"

def isExclude(f):
    result = False
    for s in default_excludes:
        result = fnmatch.fnmatch(f, s)
        if(result):
            break
    return result
def start():
    try:
        if(not os.path.exists(default_out_file)):
            os.makedirs(default_out_file)
        logF = open(default_log_file, "w+")
        logF.write("start build: " + default_conf_dir + "\n")
        logF.flush()
        models = os.listdir(default_conf_dir)
        models = [f for f in models if os.path.isdir(os.path.join(default_conf_dir, f)) and not isExclude(f)]
        for m in models:
            root = os.path.join(default_conf_dir, m)
            logF.write("START::" + root + "\n")
            logF.flush()
            for f in default_files:
                distutils.file_util.copy_file(os.path.join(default_conf_dir, f), root)
            p = subprocess.Popen([os.path.join(root, default_exe)], cwd=root, stderr=logF, stdout=logF)
            p.wait()
            distutils.file_util.copy_file(os.path.join(root, m + ".swf"), default_out_file)
            logF.flush()
            logF.write("END::" + root + "\n")
            logF.flush()
        logF.write("end build")
        logF.flush()
        logF.close()
    except:
        type_, value_, traceback_ = sys.exc_info()
        print traceback.format_exception(type_, value_, traceback_)

if __name__ == '__main__':
    start()

