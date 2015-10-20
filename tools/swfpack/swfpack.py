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
#config
#输入帧率
FPS_IN = 13
#输出帧率
FPS_OUT = 60
WIDTH = 0
HEIGHT = 0
#是否左上为中心点
CENTER_RL = True
#工具路径
IMAGE_MAGIC_PATH = "C:/Program Files/ImageMagick-6.7.5-Q16/"
SWFMILL_PATH = "E:/programFiles/swfmill/"
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

def isExclude(f):
    result = False
    for s in default_excludes:
        result = fnmatch.fnmatch(f, s)
        if(result):
            break
    return result
def start():
    try:
        global FPS_IN
        global WIDTH
        global HEIGHT
        if(not os.path.exists(default_img_out)):
            os.makedirs(default_img_out)
        logF = open(default_log_file, "w+")
        orgFiles = []
        imgFiles = []
        jpgFiles = []
        maskFiles = []
        i = 0
        path = default_conf_dir
        files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and fnmatch.fnmatch(f, default_img_file) and not fnmatch.fnmatch(f, default_mask_file)]
        logF.write(path + "::" + str(i) + "\n")
        for f in files:
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
        if(FPS_IN == 0):
		    FPS_IN = i
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
            orgInfoA[n] = eval(orgInfoA[n])
            orgInfoA[n + 1] = eval(orgInfoA[n + 1])
            orgInfoA[n + 2] = eval(orgInfoA[n + 2])
            orgInfoA[n + 3] = eval(orgInfoA[n + 3])
            i = i + 1
            if(WIDTH < orgInfoA[n + 2]):
                WIDTH = orgInfoA[n + 2]
            if(HEIGHT < orgInfoA[n + 3]):
                HEIGHT = orgInfoA[n + 3]
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
        i = 0
        n = 0
        for f in orgFiles:
            n = 4 * i
            if(CENTER_RL):
                offsetA[n] = str(eval(offsetA[n]) - (WIDTH>>1))
                offsetA[n + 1] = str(eval(offsetA[n + 1]) - (HEIGHT>>1))
            else:
                offsetA[n] = str(eval(offsetA[n]))
                offsetA[n + 1] = str(eval(offsetA[n + 1]))
            
            offsetA[n + 2] = str(eval(offsetA[n + 2]))
            offsetA[n + 3] = str(eval(offsetA[n + 3]))
            offF.write(f + " = " + offsetA[n] + " : " + offsetA[n + 1] + " , " + offsetA[n + 2] + " : " + offsetA[n + 3] + "\n")
            i = i + 1
        offF.close()
        
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
        
        i = len(jpgFiles)
        j = 0
        m = int(round(FPS_OUT / FPS_IN))
        n = 0
        clips = []
        frames = []
        for i in range(i):
            n = 4 * i
            clips.append(swfmill_clip.replace("${index}", str(i)).replace("${jpg}", jpgFiles[i].decode("gb2312")).replace("${mask}", maskFiles[i].decode("gb2312")))
            fs = swfmill_frame.replace("${index}", str(i)).replace("${x}", offsetA[n]).replace("${y}", offsetA[n + 1])
            for j in range(m):
                frames.append(fs)
        animationT = open(swfmill_templete, "r")
        animationI = open(swfmill_in, "w+")
        for line in animationT:
            line = line.replace("${fps}", str(FPS_OUT))
            line = line.replace("${width}", str(WIDTH))
            line = line.replace("${height}", str(HEIGHT))
            line = line.replace("${frames}", "\n".join(frames))
            line = line.replace("${clips}", "\n".join(clips))
            animationI.write(line)
        animationT.close()
        animationI.close()
        swfmill_out = os.path.join(MAIN_DIR, DIR_NAME + ".swf")
        args = [swfmill_exe] + swfmill_opt + [swfmill_out]
        logF.write(" ".join(args) + "\n")
        logF.flush()
        p = subprocess.Popen(args, cwd=MAIN_DIR, stderr=logF, stdout=logF)
        p.wait()
        logF.flush()
        
        if(delete_on_finish):
            shutil.rmtree(default_img_out, True)
        logF.flush()
        logF.close()
    except:
        type_, value_, traceback_ = sys.exc_info()
        print traceback.format_exception(type_, value_, traceback_)

if __name__ == '__main__':
    start()