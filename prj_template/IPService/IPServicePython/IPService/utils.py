from IPServicePython.IPService.models import *
import logging

logger = logging.getLogger(__name__)

def checkSession(request):
    valid = False
    try:
        user_id = request.session["user_id"]
        user = User.objects.get(id = user_id)
        if(user!=None):
            valid = True
    except Exception,err:
        valid = False
        logger.error(err)
    return valid

def getCurrentUser(request):
    user = None
    try:
        user_id = request.session["user_id"]
        user = User.objects.get(id = user_id)
    except Exception,err:
        logger.error(err)
    return user