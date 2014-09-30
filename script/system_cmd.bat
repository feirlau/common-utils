sc stop SysCMD
sc delete SysCMD
sc create SysCMD binPath= "cmd /K start" type= own type= interact
sc start SysCMD