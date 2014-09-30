# encoding utf-8
'''
Created on 2011-6-16

@author: loverboy
'''
import sys
import traceback
reload(sys)
sys.setdefaultencoding("utf-8")
import imp, os, codecs, fnmatch, subprocess, shutil

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
default_img_file = "*.png"
default_log_file = os.path.join(MAIN_DIR, DIR_NAME + ".log")

def start():
    try:
        logF = open(default_log_file, "w+")
        imgFiles = []
        for root, dirs, files in os.walk(default_conf_dir):
            imgs = [f for f in files if fnmatch.fnmatch(f, default_img_file)]
            if(len(imgs) > 0):
                imgFiles.append(os.path.join(root, imgs.pop()))
        logF.write("\n".join(imgFiles))
        logF.flush()
        print "Follow files will be deleted:"
        print "\n".join(imgFiles)
        input1 = raw_input("--> Do you want to delete them all(y/n) or exit(e): ")
        if(input1 != "e" and input1 != "E"):
            for f in imgFiles:
                input2 = "Y"
                if(input1 != "y" and input1 != "Y"):
                    input2 = raw_input("--> Do you want to delete file '" + f +"'(y/n): ")
                if(input2 == "y" or input2 == "Y"):
                    os.remove(f)
        logF.close()
    except:
        type_, value_, traceback_ = sys.exc_info()
        print traceback.format_exception(type_, value_, traceback_)

if __name__ == '__main__':
    start()