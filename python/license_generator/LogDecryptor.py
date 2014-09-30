import sys, os
import imp
import zlib, base64
from Crypto.Cipher import Blowfish
from PIL import Image

# the following two functions are from the py2exe wiki:
# http://www.py2exe.org/index.cgi/HowToDetermineIfRunningFromExe
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
    return os.path.normpath(tmp_dir)

MAIN_DIR = os.path.dirname(get_main_dir())
LICENSE_FILE = os.path.join(MAIN_DIR, "LogDecryptor", "license_dec.txt")
LICENSE_KEY = None
def getLicenseKey():
    global LICENSE_KEY
    if(not LICENSE_KEY):
        try:
            f = open(LICENSE_FILE, 'r')
            tmpSystemId = f.readline(1024).strip()
            tmpLicense = f.readline(1024).strip()
            if(tmpSystemId!=None and tmpSystemId!=""):
                LICENSE_KEY = decryptLicense(tmpSystemId, tmpLicense)
        except:
            pass
    return LICENSE_KEY

CLIENT_KEY = "flex_client_key@feirlau"
BLOCK_SIZE = 8
DEFAULT_IV = "12345678"
MAX_KEY_SIZE = 56

def getBlowfishKey(source_key):
    target_key = source_key
    if(source_key and len(source_key)>MAX_KEY_SIZE):
        target_key = source_key[0:MAX_KEY_SIZE]
    return target_key
def decryptLicense(system_id, license_str):
    license_key = None
    try:
        tmpKey = license_str.decode("hex")
        tmpSystemKey = getBlowfishKey(system_id.encode("hex"))
        tmpClientKey = getBlowfishKey(CLIENT_KEY.encode("hex"))
        tmpCipher = Blowfish.new(tmpClientKey, Blowfish.MODE_CBC, DEFAULT_IV)
        tmpKey = tmpCipher.decrypt(tmpKey)
        tmpCipher = Blowfish.new(tmpSystemKey, Blowfish.MODE_CBC, DEFAULT_IV)
        tmpKey = tmpCipher.decrypt(tmpKey)
        tmpLength = ord(tmpKey[len(tmpKey)-1])
        tmpKey = tmpKey[:len(tmpKey)-tmpLength]
        license_key = tmpKey.decode("hex")
    except Exception, msg:
        print msg
    return license_key

def decryptString(input_str, license_key):
    output_str = ""
    try:
        tmpInputStr = zlib.decompress(base64.b64decode(input_str))
        tmpCipher = Blowfish.new(getBlowfishKey(license_key), Blowfish.MODE_CBC, DEFAULT_IV)
        tmpOutputStr = tmpCipher.decrypt(tmpInputStr)
        tmpLength = ord(tmpOutputStr[len(tmpOutputStr)-1])
        tmpOutputStr = tmpOutputStr[:len(tmpOutputStr)-tmpLength]
        output_str = zlib.decompress(tmpOutputStr)
    except Exception, msg:
        print msg
    return output_str

def decryptImg(dec_dir, img_attrs, img_data):
    tmpSize = tuple([int(i) for i in img_attrs[2][1:-1].split(",")])
    tmpImg = Image.fromstring(img_attrs[1], tmpSize, img_data)
    tmpImg.save(os.path.join(dec_dir, img_attrs[0]))
    
def decryptTxt(dec_dir, file_name):
    source_f = open(file_name, "r")
    target_f = open(os.path.join(dec_dir, os.path.basename(file_name)), "w")
    for line in source_f:
        if(line.startswith("ENC:")):
            line = decryptString(line[4:], getLicenseKey())
        target_f.write(line)
        target_f.write("\n")
    target_f.close()
    source_f.close()

DEC_DIR = "dec_dir"
def start(argv):
    dec_dir = os.path.join(MAIN_DIR, DEC_DIR)
    for root, dirs, files in os.walk(MAIN_DIR, topdown=False):
        if(root.find(DEC_DIR)!=-1 or root.find("LogDecryptor")!=-1):
            continue
        tmpRoot = os.path.normpath(root)
        if(tmpRoot == MAIN_DIR):
            tmpPath = dec_dir
        else:
            tmpPath = tmpRoot[len(MAIN_DIR):].lstrip("\\")
            tmpPath = os.path.join(dec_dir, tmpPath)
        for name in files:
            try:
                if(not os.path.isdir(tmpPath)):
                    os.makedirs(tmpPath)
                filePath = os.path.join(tmpRoot, name)
                if(name.endswith(".kle")):
                    f = open(filePath, "r")
                    head_str = f.readline().strip()
                    head_str = decryptString(head_str, getLicenseKey())
                    tmpAttrs = head_str.split(":")
                    if(tmpAttrs[0] == "img"):
                        img_data = decryptString(f.readline(), getLicenseKey())
                        decryptImg(tmpPath, tmpAttrs[1:], img_data)
                    f.close()
                else:
                    decryptTxt(tmpPath, filePath)
            except Exception,msg:
                print msg
                pass
    
if __name__ == '__main__':
    start(sys.argv[1:])
