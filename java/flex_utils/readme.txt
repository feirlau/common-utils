Java utils used to generate manifest.xml for flex swc libraries.
Usage:
FlexManifestHelper srcPath packages manifest excludeFile globalManifest token readToken

About args:
srcPath = "D:\\compc"; //root path of source codes.
packages = "D:\\compc\\org\\feirlau"; //packages to be included in manifest file, seperator of list is ';'.
manifest = "D:\\compc\\compc-manifest.xml"; //path of manifest file.
excludeFile = "D:\\excludes.txt"; //path of exclude file list.
globalManifest = "D:\\global-manifest.xml"; //the path of global menifest file.
token = "all"; //('mxml'/'metadata'/'both'/'all') is the token to determin to add to menifest file.
readToken = "false"; //the flag whether read the manifest token form the file to get the component name.