import sys
import os
import subprocess
import md5
import imp
import locale
import zlib, base64
import time
from Crypto.Cipher import Blowfish

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
    return os.path.normpath(tmp_dir)

def to_unicode(x):
    """Try to convert the input to utf-8."""
    
    # return empty string if input is None
    if x is None:
        return ''
    
    # if this is not a string, let's try converting it
    if not isinstance(x, basestring):
        x = str(x)
        
    # if this is a unicode string, encode it and return
    if isinstance(x, unicode):
        return x.encode('utf-8')
    
    # now try a bunch of likely encodings
    encoding = locale.getpreferredencoding()
    try:
        ret = x.decode(encoding).encode('utf-8')
    except UnicodeError:
        try:
            ret = x.decode('utf-8').encode('utf-8')
        except UnicodeError:
            try:
                ret = x.decode('latin-1').encode('utf-8')
            except UnicodeError:
                ret = x.decode('utf-8', 'replace').encode('utf-8')
    return ret

# The license check relative code
MAIN_DIR = get_main_dir()
dmi_sum = "bca173dc4758676dd812c7632017d0ae"
DMIDECODE = os.path.join(MAIN_DIR, "data/dmidecode.exe")
LICENSE_FILE = os.path.join(MAIN_DIR, "data/license.txt")
LICENSE_STR = None
LICENSE_MASK = "asdf1234@feirlau"
LICENSE_KEY = None
LICENSE_TIME = None

def getSystemUUID():
    tmpUUID = ""
    cmd = '"' + DMIDECODE + '" -s system-uuid'
    process = subprocess.Popen(cmd, shell=True, bufsize=-1, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    process.wait()
    for line in process.stdout:
        tmpUUID = line
        break
    return tmpUUID
def sumfile(fobj):
    '''Returns an md5 hash for an object with read() method.'''
    m = md5.new()
    while True:
        d = fobj.read(8096)
        if not d:
            break
        m.update(d)
    return m.hexdigest()
def md5sum(fname):
    '''Returns an md5 hash for file fname, or stdin if fname is "-".'''
    try:
        f = file(fname, 'rb')
    except:
        return None
    ret = sumfile(f)
    f.close()
    return ret

def getLicenseTime():
    global LICENSE_TIME
    if(not LICENSE_TIME):
        try:
            if(dmi_sum==utils.md5sum(DMIDECODE)):
                systemId = getSystemUUID()
                if(systemId!=None and systemId!=""):
                    LICENSE_TIME = float(decryptLicense(systemId, getLicenseStr()))
        except:
            pass
    return LICENSE_TIME
def checkLicenseExpired():
    licenseExpired = True
    try:
        licenseTime = getLicenseTime()
        import time
        if(licenseTime and time.time()<=licenseTime):
            licenseExpired = False
    except:
        pass
    return licenseExpired
def checkLicense():
    licenseValidate = False
    try:
        if(dmi_sum==md5sum(DMIDECODE)):
            systemId = getSystemUUID()
            if(systemId!=None and systemId!="" and LICENSE_MASK==decryptLicense(systemId, getLicenseStr())):
                licenseValidate = True
    except:
        pass
    return licenseValidate
def getLicenseStr():
    global LICENSE_STR
    if(not LICENSE_STR):
        try:
            f = open(LICENSE_FILE, 'r')
            LICENSE_STR = f.readline(1024).strip()
        except:
            pass
    return LICENSE_STR

def getLicenseKey():
    global LICENSE_KEY
    if(not LICENSE_KEY):
        try:
            f = open(LICENSE_FILE, 'r')
            f.readline(1024)
            tmpLicense = f.readline(1024).strip()
            if(dmi_sum==md5sum(DMIDECODE)):
                systemId = getSystemUUID()
                if(systemId!=None and systemId!=""):
                    LICENSE_KEY = decryptLicense(systemId, tmpLicense)
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
# The IV has contains in the license_str when encrypt
def encryptLicense(system_id, license_key):
    license_str = None
    try:
        tmpSystemKey = getBlowfishKey(system_id.encode("hex"))
        tmpClientKey = getBlowfishKey(CLIENT_KEY.encode("hex"))
        tmpLicenseKey = license_key.encode("hex")
        tmpLength = BLOCK_SIZE - len(tmpLicenseKey)%BLOCK_SIZE
        for i in range(tmpLength):
            tmpLicenseKey = tmpLicenseKey + chr(tmpLength)
        tmpCipher = Blowfish.new(tmpSystemKey, Blowfish.MODE_CBC, DEFAULT_IV)
        tmpStr = tmpCipher.encrypt(tmpLicenseKey)
        tmpCipher = Blowfish.new(tmpClientKey, Blowfish.MODE_CBC, DEFAULT_IV)
        tmpStr = tmpCipher.encrypt(tmpStr)
        license_str = tmpStr.encode("hex")
    except Exception, msg:
        print msg
    return license_str

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

def encryptString(input_str, license_key):
    output_str = ""
    try:
        tmpInputStr = zlib.compress(input_str)
        tmpLength = BLOCK_SIZE - len(tmpInputStr)%BLOCK_SIZE
        for i in range(tmpLength):
            tmpInputStr = tmpInputStr + chr(tmpLength)
        tmpCipher = Blowfish.new(getBlowfishKey(license_key), Blowfish.MODE_CBC, DEFAULT_IV)
        tmpOutputStr = tmpCipher.encrypt(tmpInputStr)
        output_str = base64.b64encode(zlib.compress(tmpOutputStr))
    except Exception, msg:
        print msg
    return output_str

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
