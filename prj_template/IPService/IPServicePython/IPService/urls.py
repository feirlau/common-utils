from django.conf.urls.defaults import *
from IPServicePython.IPService.views import *

# Define the url mapping of sub apps
urlpatterns = patterns('IPServicePython.IPService.views',
    # Example
    # (r'^login$', 'login'),
    # (r'^home$', 'getHomePage'),
    (r'^action$', func),
)