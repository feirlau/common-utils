from django.conf.urls.defaults import url, patterns, include
from IPServicePython import settings
from IPServicePython.IPService import urls as appurls
# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # include the url mapping of sub apps, such as IPService/urls.py
    url(r'^ipservice/', include(appurls)),
    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
    
    # Static resources using django static servlet
    url(r'^static/(?P<path>.*)$','django.views.static.serve',{'document_root':settings.STATIC_PATH}),
    url(r'^/?$', 'django.views.static.serve', {'path':'JewelFlex.html', 'document_root':settings.STATIC_PATH}),
    url(r'^(?P<path>.*)$', 'django.views.static.serve', {'document_root':settings.STATIC_PATH}),
)
