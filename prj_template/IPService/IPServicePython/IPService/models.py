from django.db import models

# Create your models here.
class UserInfo(models.Model):
    des = models.CharField(max_length=1024)
    email = models.EmailField(max_length=64, null=False)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True, auto_now_add=True)
    others = models.XMLField()
class User(models.Model):
    username = models.CharField(max_length=64, null=False)
    password = models.CharField(max_length=64, null=False)
    name = models.CharField(max_length=64)
    type = models.IntegerField(default=1)
    info = models.ForeignKey(UserInfo)