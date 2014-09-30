# encoding utf-8
'''
pack pngs to jsa(javascript animation)
Created on 2014-6-30

@author: risker
'''
import sys
import traceback
reload(sys)
sys.setdefaultencoding("utf-8")
import imp, os, codecs, fnmatch, subprocess, shutil, distutils.file_util, zlib, zipfile
import jsonpickle, json
import jsa

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

DEBUG = True
MAIN_DIR = get_main_dir()
DIR_NAME = os.path.split(MAIN_DIR)[1]
default_conf_dir = MAIN_DIR
#默认图片压缩格式
default_data_type = jsa.JSADataType.GRAY_SCALE_JPG
default_png_file = "*.png"
default_jpg_file = "*.jpg"
default_info_file = "info.json"
default_img_out = os.path.normpath(os.path.join(MAIN_DIR, "out"))
default_log_file = os.path.join(MAIN_DIR, DIR_NAME + ".log")
default_out_file = os.path.join(MAIN_DIR, "jsa.json")
default_out_file_zip = os.path.join(default_img_out, "jsa.json.zip")
default_jsa_file = os.path.join(MAIN_DIR, DIR_NAME + "_" + str(default_data_type) + ".jsa")
default_excludes = ["out", ".*"]
default_password = ""

#剪裁图片
img_mogrify_exe = "C:/Program Files/ImageMagick-6.7.5-Q16/mogrify.exe"
img_mogrify_opt = ['-trim']

#获取图片剪裁信息
img_identify_exe = "C:/Program Files/ImageMagick-6.7.5-Q16/identify.exe"
img_identify_opt = ['-format', '0%X,0%Y,%w,%h']

#提取图片透明度信息，生成mask图
img_mogrify_mask_exe = "C:/Program Files/ImageMagick-6.7.5-Q16/mogrify.exe"
#生成gray-scale-jpg的mask图
img_mogrify_mask_opt_3 = ['-alpha', 'extract', '-format']
img_mogrify_mask_img_3 = 'mask.jpg'
#生成alpha-png的mask图
img_mogrify_mask_opt_4 = ['-alpha', 'extract', '-alpha', 'on', '-format']
img_mogrify_mask_img_4 = 'mask.png'

#转换成jpg格式，去除alpha信息
img_mogrify_jpg_exe = "C:/Program Files/ImageMagick-6.7.5-Q16/mogrify.exe"
img_mogrify_jpg_opt = ['-format', 'jpg', '-background', 'black', '-alpha', 'remove', '-quality', '80%']

def toUnicode(s, type = 'gbk'):
    return unicode(s, type)
    
def toAbs(s, type = 'gbk', root = None):
    if(None == root):
        root = default_img_out
    s = s[len(root):]
    s = os.path.normpath(s)
    s = s.replace("\\", "/");
    if (len(s) > 0 and s[0] == "/"):
        s = s[1:]
    return toUnicode(s, type)
    
def isExclude(f):
    result = False
    for s in default_excludes:
        result = fnmatch.fnmatch(f, s)
        if(result):
            break
    return result
    
def parseFile(f, jsaObj, logF, out):
    if(None == jsaObj):
        jsaObj = jsa.JSAPack()
    name = os.path.split(f)[1]
    base = os.path.splitext(name)[0]
    jsaObj.name = toUnicode(name)
    jsaObj.path = toAbs(os.path.join(out, name))
    jsaObj.type = jsa.JSAType.FILE
    data = jsa.JSAData()
    jsaObj.data = data
    
    if(fnmatch.fnmatch(f, default_png_file)):
        tmpName = os.path.join(out, name)
        distutils.file_util.copy_file(f, tmpName)
        
        args = [img_mogrify_exe] + img_mogrify_opt + [tmpName]
        logF.write(" ".join(args) + "\n")
        logF.flush()
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=subprocess.PIPE)
        p.wait()
        logF.flush()
        
        args = [img_identify_exe] + img_identify_opt + [tmpName]
        logF.write(" ".join(args) + "\n")
        logF.flush()
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=subprocess.PIPE)
        p.wait()
        logF.flush()
        
        offsetInfo = p.stdout.readline().strip()
        logF.write(offsetInfo + "\n")
        offsetA = offsetInfo.split(",")[0:4]
        offsetA[0] = eval(offsetA[0])
        offsetA[1] = eval(offsetA[1])
        offsetA[2] = eval(offsetA[2])
        offsetA[3] = eval(offsetA[3])
        
        if(default_data_type == jsa.JSADataType.NORMAL_PNG):
            #保持原版png格式，不压缩
            data.type = jsa.JSADataType.NORMAL_PNG
            data.src = toUnicode(name)
        else:
            args = [img_mogrify_jpg_exe] + img_mogrify_jpg_opt + [tmpName]
            logF.write(" ".join(args) + "\n")
            logF.flush()
            p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
            p.wait()
            logF.flush()
            
            img_mogrify_mask_opt = img_mogrify_mask_opt_3
            img_mogrify_mask_img = img_mogrify_mask_img_3
            data.type = jsa.JSADataType.GRAY_SCALE_JPG
            if(default_data_type == jsa.JSADataType.GRAY_SCALE_PNG):
                data.type = jsa.JSADataType.GRAY_SCALE_PNG
                img_mogrify_mask_img = img_mogrify_mask_img_4
            if(default_data_type == jsa.JSADataType.ALPHA_PNG):
                data.type = jsa.JSADataType.ALPHA_PNG
                img_mogrify_mask_opt = img_mogrify_mask_opt_4
                img_mogrify_mask_img = img_mogrify_mask_img_4
                
            args = [img_mogrify_mask_exe] + img_mogrify_mask_opt + [img_mogrify_mask_img, tmpName]
            logF.write(" ".join(args) + "\n")
            logF.flush()
            p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
            p.wait()
            logF.flush()
        
            os.remove(tmpName)
            tmpName = base + ".jpg"
            data.src = toUnicode(tmpName)
            tmpName = base + "." + img_mogrify_mask_img
            data.mask = toUnicode(tmpName)
        data.offset = offsetA
    elif(fnmatch.fnmatch(f, default_jpg_file)):
        tmpName = os.path.join(out, name)
        distutils.file_util.copy_file(f, tmpName)
        data.src = toUnicode(name)
        data.type = jsa.JSADataType.NORMAL_JPG
    else:
        jsaObj = None
    
    return jsaObj
    
def parseDir(d, jsaObj, logF, out):
    if(None == jsaObj):
        jsaObj = jsa.JSAPack()
    name = os.path.split(d)[1]
    jsaObj.name = toUnicode(name)
    jsaObj.path = toAbs(out)
    jsaObj.type = jsa.JSAType.FOLDER
    items = []
    jsaObj.items = items
    files = os.listdir(d)
    for f in files:
        if(isExclude(f)):
            continue
        f_abs = os.path.join(d, f)
        if(os.path.isdir(f_abs)):
            d_abs = os.path.join(out, f);
            if(not os.path.exists(d_abs)):
                os.makedirs(d_abs)
            items.append(parseDir(f_abs, None, logF, d_abs))
        elif(f == default_info_file):
            fH = open(f_abs, "r")
            jsaObj.info = jsonpickle.decode(fH.read())
        else:
            tmpJsa = parseFile(f_abs, None, logF, out)
            if(tmpJsa):
                items.append(tmpJsa)
    return jsaObj

def start():
    try:
        if(os.path.exists(default_img_out)):
            shutil.rmtree(default_img_out, True)
        os.makedirs(default_img_out)
        
        logF = open(default_log_file, "w+")
        
        jsaObj = parseDir(default_conf_dir, None, logF, default_img_out)
        
        outF = open(default_out_file, "w")
        s = jsonpickle.encode(jsaObj)
        if(DEBUG):
            jsaObj = json.loads(s)
            s = json.dumps(jsaObj, indent=4)
        outF.write(s)
        outF.flush()
        outF.close()
        
        outF = open(default_out_file_zip, "wb")
        outF.write(zlib.compress(s))
        outF.flush()
        outF.close()
        
        logF.flush()
        logF.close()
        
        zf = zipfile.ZipFile(default_jsa_file, "w", zipfile.ZIP_STORED)
        if(default_password):
            zf.setpassword(default_password)
        for dirpath, dirnames, filenames in os.walk(default_img_out, True):
            fs = dirnames + filenames
            for f in fs:
                f = os.path.join(dirpath, f)
                af = toAbs(f)
                zf.write(f, af)
        zf.close()
    except:
        type_, value_, traceback_ = sys.exc_info()
        print traceback.format_exception(type_, value_, traceback_)

if __name__ == '__main__':
    start()