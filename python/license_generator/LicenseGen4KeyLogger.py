import sys, time
from Crypto.Cipher import Blowfish

LICENSE_FILE = "data/license.txt"
LICENSE_FILE_DEC = "data/license_dec.txt"
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

def start(argv):
    tmpTime = time.mktime(time.strptime(argv[1], "%Y-%m-%d"))
    license1 = encryptLicense(argv[0], str(tmpTime))
    license2 = encryptLicense(argv[0], argv[2])
    licenseFile = open(LICENSE_FILE, "w")
    licenseFile.write(license1)
    licenseFile.write("\n")
    licenseFile.write(license2)
    licenseFile.close()
    licenseFileDec = open(LICENSE_FILE_DEC, "w")
    licenseFileDec.write(argv[0])
    licenseFileDec.write("\n")
    licenseFileDec.write(license2)
    licenseFileDec.close()
    
if __name__ == '__main__':
    print "Usage:\n LicenseGen4KeyLogger system_uuid expired_date(such as 2011-01-02) license_key"
    start(sys.argv[1:])
    print "License file has generated!"