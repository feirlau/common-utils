import sys, time
from Crypto.Cipher import Blowfish

LICENSE_FILE = "data/license.txt"
LICENSE_FILE_PLAIN = "data/license_plain.txt"
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

def start(argv):
    licenseFile = open(LICENSE_FILE, "r")
    license1 = licenseFile.readline(1024).strip()
    license2 = licenseFile.readline(1024).strip()
    licenseFile.close()
    licenseTime = time.strftime("%Y-%m-%d", time.localtime(float(decryptLicense(argv[0], license1))))
    licenseKey = decryptLicense(argv[0], license2)
    licensePlain = open(LICENSE_FILE_PLAIN, "w")
    licensePlain.write(licenseTime)
    licensePlain.write("\n")
    licensePlain.write(licenseKey)
    licensePlain.close()
    
if __name__ == '__main__':
    print "Usage:\n LicenseDec4KeyLogger system_uuid"
    start(sys.argv[1:])
    print "License file has decrypted!"