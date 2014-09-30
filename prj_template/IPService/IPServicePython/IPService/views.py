# Create your views here.
from django.views.decorators.cache import never_cache
from django.shortcuts import render_to_response
from IPServicePython.IPService.models import *
from IPServicePython.IPService.utils import *

# import the logging library
import logging

# Get an instance of a logger
logger = logging.getLogger(__name__)

@never_cache
def func(request):
    try:
        if(not checkSession(request)):
            return render_to_response("result.xml", {"resultCode": -3})
        return render_to_response("result.xml", {"resultCode": 1})
    except Exception, err:
        logger.error(err)
        return render_to_response("result.xml", {"resultCode": -1})
