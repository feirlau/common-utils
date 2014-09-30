Note:
1. Please do not include file or dir with the same name of project, that's "IPServicePython", in directory of project. Otherwise, there will be error like "Error: Could not import settings 'IPServicePython.settings' (Is it on sys.path? Does it have syntax errors?): No module named settings"!
2. Please use IPServicePython as the root package to make the project work when package using py2exe
3. Please use settings.BASEDIR as the root dir to make the project work when package using py2exe
4. Please don't put it in any directory with charater other then english or with space, otherwise there will be some unexcept problems, such as error: [Errno 10054] 