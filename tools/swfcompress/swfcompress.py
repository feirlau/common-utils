# encoding utf-8
'''
Created on 2011-6-16

@author: loverboy
'''
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
default_excludes = [".*", "out"]
default_conf_dir = MAIN_DIR
default_out_dir = os.path.join(MAIN_DIR, "out")
default_img_file = "*.swf"
default_log_file = os.path.join(MAIN_DIR, DIR_NAME + ".log")
default_tmp_file = "tmp_out.swf"
#去除debug
stripper_enable = False
stripper_exe = "stripper.bat"
#字节码优化
tdsi_enable = True
tdsi_exe = "tdsi.bat"
#压缩swf
reducer_enable = True
reducer_exe = "reducer.bat"
reducer_opt = ['-q', '0.8']

def isExclude(f):
    result = False
    for s in default_excludes:
        result = fnmatch.fnmatch(f, s)
        if(result):
            break
    return result
def listFiles(dir):
    files = []
    for f in os.listdir(dir):
        if(isExclude(f)):
            continue
        f = os.path.join(dir, f)
        if(os.path.isdir(f)):
            files = files + listFiles(f)
        elif(fnmatch.fnmatch(f, default_img_file)):
            files.append(f)
    return files
def start():
    try:
        if(os.path.exists(default_out_dir)):
            shutil.rmtree(default_out_dir)
        os.makedirs(default_out_dir)
        logF = open(default_log_file, "w+")
        imgFiles = listFiles(default_conf_dir)
        
        for f in imgFiles:
            tmpOut = f.replace(default_conf_dir, default_out_dir, 1)
            d = os.path.dirname(tmpOut)
            if(not os.path.exists(d)):
                os.makedirs(d)
            if(stripper_enable):
                args = [stripper_exe] + ['-i', f, '-o', tmpOut]
                logF.write(" ".join(args) + "\n")
                p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
                p.wait()
                logF.flush()
                f = tmpOut
            if(tdsi_enable):
                args = [tdsi_exe] + ['-i', f, '-o', tmpOut]
                logF.write(" ".join(args) + "\n")
                p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
                p.wait()
                logF.flush()
                f = tmpOut
            if(reducer_enable):
                args = [reducer_exe] + ['-i', f, '-o', tmpOut] + reducer_opt
                logF.write(" ".join(args) + "\n")
                p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
                p.wait()
                logF.flush()
        logF.close()
    except:
        type_, value_, traceback_ = sys.exc_info()
        print traceback.format_exception(type_, value_, traceback_)

if __name__ == '__main__':
    start()