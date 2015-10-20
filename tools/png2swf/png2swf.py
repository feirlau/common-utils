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
default_conf_dir = MAIN_DIR
default_mask_file = "*.mask.png"
default_img_file = "*.png"
default_img_out = os.path.normpath(os.path.join(MAIN_DIR, "imgs"))
default_log_file = os.path.join(MAIN_DIR, DIR_NAME + ".log")
default_excludes = ["imgs", ".*"]
delete_on_finish = True
default_static_dir = os.path.join(default_conf_dir, "static")
#config
ALL_IN_ONE_SWF = True
IMAGE_MAGIC_PATH = "C:/Program Files/ImageMagick-6.7.5-Q16/"
SWFMILL_PATH = "E:/programFiles/swfmill/"
SWFTOOLS_PATH = "E:/programFiles/swftools/"
#剪裁图片
img_mogrify_exe = IMAGE_MAGIC_PATH + "mogrify.exe"
img_mogrify_opt = ['-trim']

#获取图片剪裁信息
img_identify_exe = IMAGE_MAGIC_PATH + "identify.exe"
img_identify_opt = ['-format', '0%X,0%Y,%w,%h,']
img_identify_out = os.path.join(MAIN_DIR, "offset.txt")
img_identify_out_org = os.path.join(MAIN_DIR, "offsetOrg.txt")

#提取图片透明度信息，生成mask图
img_mogrify_mask_exe = IMAGE_MAGIC_PATH + "mogrify.exe"
img_mogrify_mask_opt = ['-format', 'mask.png', '-alpha', 'extract']

#转换成jpg格式，去除alpha信息
img_mogrify_jpg_exe = IMAGE_MAGIC_PATH + "mogrify.exe"
img_mogrify_jpg_opt = ['-format', 'jpg', '-background', 'black', '-alpha', 'remove', '-quality', '80%']

#生成图片动画swf
swfmill_clip = '<clip id="mc${index}" import="${jpg}" mask="${mask}"/>'
swfmill_frame = '<frame><place id="mc${index}" depth="1" x="${x}" y="${y}"/></frame>'
swfmill_in = os.path.join(MAIN_DIR, "animation.xml")
swfmill_templete = os.path.join(MAIN_DIR, "templete_animation.xml")
swfmill_exe = SWFMILL_PATH+"swfmill.exe"
swfmill_opt = ['simple', swfmill_in]

#生成包含图片偏移以及动作信息的swf
swfc_in = os.path.join(MAIN_DIR, "offset.sc")
swfc_templete = os.path.join(MAIN_DIR, "templete_offset.sc")
swfc_out = os.path.join(MAIN_DIR, "offset.swf")
swfc_exe = SWFTOOLS_PATH+"swfc.exe"
swfc_opt = ['-o', swfc_out, swfc_in]

#合并动画和偏移信息的swf
swfcombine_out = os.path.join(MAIN_DIR, DIR_NAME + ".swf")
swfcombine_exe = SWFTOOLS_PATH+"swfcombine.exe"
swfcombine_opt1 = ['-o', swfcombine_out, '-X', '512', '-Y', '512', '-za']
swfcombine_opt2 = ['-o', swfcombine_out, '-X', '512', '-Y', '512', '-zmf', swfc_out, "#1=" + swfcombine_out]


def isExclude(f):
    result = False
    for s in default_excludes:
        result = fnmatch.fnmatch(f, s)
        if(result):
            break
    return result
def start():
    try:
        if(not os.path.exists(default_img_out)):
            os.makedirs(default_img_out)
        logF = open(default_log_file, "w+")
        orgFiles = []
        imgFiles = []
        jpgFiles = []
        maskFiles = []
        frameIndexs = []
        actionIndexs = []
        i = 0
        actions = os.listdir(default_conf_dir)
        actions = [f for f in actions if os.path.isdir(os.path.join(default_conf_dir, f)) and not isExclude(f)]
        for action in actions:
            root = os.path.join(default_conf_dir, action)
            actionIndexs.append(i)
            path = root
            files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and fnmatch.fnmatch(f, default_img_file) and not fnmatch.fnmatch(f, default_mask_file)]
            logF.write(path + "::" + str(i) + "\n")
            prefixDir = ""
            for f in files:
                if(not prefixDir or not f.startswith(prefixDir)):
                    frameIndexs.append(i)
                    prefixDir = f[0:2];
                p1 = os.path.join(path, f)
                orgFiles.append(p1)
                p2 = os.path.join(default_img_out, str(i) + ".png")
                shutil.copy(p1, p2)
                imgFiles.append(p2)
                p2 = os.path.join(default_img_out, str(i) + ".jpg")
                jpgFiles.append(p2.replace("\\", "/"))
                p2 = os.path.join(default_img_out, str(i) + ".mask.png")
                maskFiles.append(p2.replace("\\", "/"))
                i = i + 1
        frameIndexs.append(i)
        actionIndexs.append(i)
        logF.write("END::" + str(i) + "\n")
        logF.flush()
        
        args = [img_mogrify_exe] + img_mogrify_opt + imgFiles
        logF.write(" ".join(args) + "\n")
        logF.flush()
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
        p.wait()
        logF.flush()
        
        args = [img_identify_exe] + img_identify_opt + orgFiles

        logF.write(" ".join(args) + "\n")
        logF.flush()
        offF = open(img_identify_out_org, "w+")
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=offF)
        p.wait()
        logF.flush()
        offF.flush()
        offF.seek(0)
        orgImgInfo = offF.readline().strip()
        orgInfoA = orgImgInfo.split(",")
        n = 0
        i = 0
        offF.seek(0)
        for f in orgFiles:
            n = 4 * i
            #print(n, orgInfoA[n])
            orgInfoA[n] = str(eval(orgInfoA[n]))
            orgInfoA[n + 1] = str(eval(orgInfoA[n + 1]))
            orgInfoA[n + 2] = str(eval(orgInfoA[n + 2]))
            orgInfoA[n + 3] = str(eval(orgInfoA[n + 3]))  
           # offF.write(f + " = " + orgInfoA[n] + " : " + orgInfoA[n + 1] + " , " + str(int(orgInfoA[n + 2])>>1) + " : " + str(int(orgInfoA[n + 3])>>1) + "\n")
            i = i + 1
        offF.close()
        
        args = [img_identify_exe] + img_identify_opt + imgFiles
        logF.write(" ".join(args) + "\n")
        logF.flush()
        offF = open(img_identify_out, "w+")
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=offF)
        p.wait()
        logF.flush()
        offF.flush()
        offF.seek(0)
        offsetInfo = offF.readline().strip()
        offF.seek(0)
        offsetA = offsetInfo.split(",")
        offsetInfo = []
        boxInfoW = 0
        boxInfoH = 0
        i = 0
        j = 0
        n = 0
        for f in orgFiles:
            n = 4 * i
            offsetA[n] = str(eval(offsetA[n]))
            offsetA[n + 1] = str(eval(offsetA[n + 1]))
            offsetA[n] = str(int(offsetA[n]) - (int(orgInfoA[n + 2])>>1))
            offsetA[n + 1] = str(int(offsetA[n + 1]) - (int(orgInfoA[n + 3])>>1))
            offsetA[n + 2] = str(eval(offsetA[n + 2]))
            offsetA[n + 3] = str(eval(offsetA[n + 3]))
            if(f.startswith(default_static_dir)):
                j = int(offsetA[n + 2])
                if(boxInfoW < j):
                    boxInfoW = j
                j = int(offsetA[n + 3])
                if(boxInfoH < j):
                    boxInfoH = j
            offsetInfo.append(offsetA[n])
            offsetInfo.append(offsetA[n + 1])
            offF.write(f + " = " + offsetA[n] + " : " + offsetA[n + 1] + " , " + offsetA[n + 2] + " : " + offsetA[n + 3] + "\n")
            i = i + 1
        offF.close()
        offsetInfo = ",".join(offsetInfo)
        boxInfo = ",".join([str(boxInfoW), str(boxInfoH)])
        
        args = [img_mogrify_jpg_exe] + img_mogrify_jpg_opt + imgFiles
        logF.write(" ".join(args) + "\n")
        logF.flush()
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
        p.wait()
        logF.flush()
        
        args = [img_mogrify_mask_exe] + img_mogrify_mask_opt + imgFiles
        logF.write(" ".join(args) + "\n")
        logF.flush()
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
        p.wait()
        logF.flush()
        
        i = len(actionIndexs) - 1
        j = 0
        k = 0
        n = 0
        swfcombine_ins = []
        for i in range(i):
            action = actions[i]
            j = actionIndexs[i]
            k = actionIndexs[i+1]
            if(j == k):
                continue
            clips = []
            frames = []
            for i in range(j, k):
                n = 4 * i
                clips.append(swfmill_clip.replace("${index}", str(i)).replace("${jpg}", jpgFiles[i].decode("gb2312")).replace("${mask}", maskFiles[i].decode("gb2312")))
                frames.append(swfmill_frame.replace("${index}", str(i)).replace("${x}", offsetA[n]).replace("${y}", offsetA[n + 1]))
            animationT = open(swfmill_templete, "r")
            animationI = open(swfmill_in, "w+")
            for line in animationT:
                line = line.replace("${frames}", "\n".join(frames))
                line = line.replace("${clips}", "\n".join(clips))
                animationI.write(line)
            animationT.close()
            animationI.close()
            swfmill_out = os.path.join(MAIN_DIR, DIR_NAME + "_" + action + ".swf")
            args = [swfmill_exe] + swfmill_opt + [swfmill_out]
            logF.write(" ".join(args) + "\n")
            logF.flush()
            p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
            p.wait()
            logF.flush()
            if(ALL_IN_ONE_SWF or action.startswith("static")):
                swfcombine_ins.append(swfmill_out)
        
        offsetT = open(swfc_templete, "r")
        offsetI = open(swfc_in, "w+")
        frameInfo = ",".join(str(var) for var in frameIndexs)
        actionIndex = ",".join(str(var) for var in actionIndexs)
        actions = [f.decode("gb2312") for f in actions]
        actionInfo = '"' + '","'.join(actions) + '"'
        for line in offsetT:
            line = line.replace("${package_name}", "_lf_model_" + DIR_NAME.decode("gb2312"))
            line = line.replace("${offset_info}", offsetInfo)
            line = line.replace("${frame_info}", frameInfo)
            line = line.replace("${action_index}", actionIndex)
            line = line.replace("${action_info}", actionInfo)
            line = line.replace("${box_info}", boxInfo)
            offsetI.write(line)
        offsetT.close()
        offsetI.close()
        args = [swfc_exe] + swfc_opt
        logF.write(" ".join(args) + "\n")
        logF.flush()
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
        p.wait()
        
        if(len(swfcombine_ins) > 0):
            if(len(swfcombine_ins) > 1):
                args = [swfcombine_exe] + swfcombine_opt1 + swfcombine_ins
                logF.write(" ".join(args) + "\n")
                logF.flush()
            else:
                distutils.file_util.copy_file(swfcombine_ins[0], swfcombine_out)
            p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
            p.wait()
            args = [swfcombine_exe] + swfcombine_opt2
            logF.write(" ".join(args) + "\n")
            logF.flush()
            p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
            p.wait()
        else:
            logF.write("copy " + swfc_out + " to " + swfcombine_out + "\n")
            distutils.file_util.copy_file(swfc_out, swfcombine_out)
        if(delete_on_finish):
            shutil.rmtree(default_img_out, True)
        logF.flush()
        logF.close()
    except:
        type_, value_, traceback_ = sys.exc_info()
        print traceback.format_exception(type_, value_, traceback_)

if __name__ == '__main__':
    start()