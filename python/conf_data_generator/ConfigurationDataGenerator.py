# encoding utf-8
'''
Created on 2011-6-16

@author: loverboy
'''
import sys
import traceback
reload(sys)
sys.setdefaultencoding("utf-8")
import imp, os, xlrd, codecs, base64
from xml.dom import minidom

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

MAIN_DIR = get_main_dir()
default_conf_dir = os.path.join(MAIN_DIR, "conf")
default_output = os.path.join(MAIN_DIR, "generated/data")
data_configuration_postfix = "data_conf.xml"

def getDataValue(cellValue, cellType):
    tmpValue = cellValue
    if(cellType == "int"):
        tmpValue = int(cellValue)
    elif(cellType == "long"):
        tmpValue = long(cellValue)
    elif(cellType == "float" or cellType == "double"):
        tmpValue = float(cellValue)
    elif(cellType == "date"):
        tmpValue = float(cellValue)
    elif(cellType == "string"):
        tmpValue = str(cellValue)
    return tmpValue
    
def generateConfData(confFile):
    try:
        print "Started: %s"%confFile
        conf_file = open(confFile)
        conf_dom = minidom.parse(conf_file)
        conf_element = conf_dom.documentElement
        data_file = conf_element.getAttribute("from")
        data_file = os.path.join(default_conf_dir, data_file)
        data_sheet = conf_element.getAttribute("sheet_name")
        output_file = conf_element.getAttribute("name")
        output_type = conf_element.getAttribute("type")
        if(output_type):
            output_file = output_file + "_" + output_type
        output_file = os.path.join(default_output, output_file + ".txt")
        outputFile = open(output_file, "w")
        # outputFile.write(codecs.BOM_UTF8)
        attrList = conf_element.getElementsByTagName("attr")
        dataBook = xlrd.open_workbook(data_file, encoding_override="utf_8")
        dataSheet = dataBook.sheet_by_name(data_sheet)
        rowIndexs = []
        colName = "";
        for i in range(dataSheet.ncols):
            try:
                colName = getDataValue(dataSheet.cell(0, i).value, "string")
                rowIndexs.append(colName)
            except:
                print 'Parse header failed:: column=' + str(i)
                type_, value_, traceback_ = sys.exc_info()
                print traceback.format_exception(type_, value_, traceback_)
        for i in range(1, dataSheet.nrows):
            dataRow = []
            for attrItem in attrList:
                colName = attrItem.getAttribute("col_name")
                colType = attrItem.getAttribute("type")
                cellValue = ""
                try:
                    cellValue = dataSheet.cell(i, rowIndexs.index(colName)).value
                    cellValue = getDataValue(cellValue, colType)
                except:
                    print 'Parse cell failed:: column= ' + colName + ', row=' + str(i) + ', type=' + colType
                    type_, value_, traceback_ = sys.exc_info()
                    print traceback.format_exception(type_, value_, traceback_)
                dataRow.append(str(cellValue))
            outputFile.write("\t".join(dataRow))
            outputFile.write("\n")
        outputFile.close()
        print "Successed: %s"%confFile
    except:
        print "Failed: %s"%confFile
        type_, value_, traceback_ = sys.exc_info()
        msg = traceback.format_exception(type_, value_, traceback_)
        print msg

def start():
    try:
        if(not os.path.exists(default_output)):
            os.makedirs(default_output)
        confFiles = os.listdir(default_conf_dir)
        confFiles = [f for f in confFiles if f.endswith(data_configuration_postfix)]
        for confFile in confFiles:
            generateConfData(os.path.join(default_conf_dir, confFile))
    except:
        type_, value_, traceback_ = sys.exc_info()
        print traceback.format_exception(type_, value_, traceback_)

if __name__ == '__main__':
    start()