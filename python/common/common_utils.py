import logging
import re

agent_oss = ['Windows', 'Linux', 'Mac OS', 'FreeBSD']
agent_browsers = ['MSIE', 'Opera', 'Chrome', 'Safari', 'Firefox']
# get os and browser info from user agent string of client request
# @return [os_info, browser_info]
def getUserAgentInfo(agent_str):
    os_info = 'Unknow'
    browser_info = 'Unknow'
    try:
        for agent_os in agent_oss:
            if(agent_str.index(agent_os)>0):
                os_info = agent_os
                break
        for agent_browser in agent_browsers:
            browser_re = agent_browser + '[/ ]((\d+\.)+\d+)'
            browser_mo = re.search(browser_re, agent_str)
            if(None != browser_mo):
                browser_info = browser_mo.group(0)
                break
    except Exception, msg:
        logging.debug(msg)
    return [os_info, browser_info]

# get the special item from the source_str, split the string by spliter    
def getItemFromString(source_str, item_index=0, spliter="/"):
    result_str = ""
    try:
        result_str = source_str.split(spliter)[item_index]
    except Exception, msg:
        logging.debug(msg)
    return result_str