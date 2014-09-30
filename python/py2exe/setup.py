from distutils.core import setup
import py2exe
import os

def add_path_tree( base_path, path, skip_dirs=[ '.svn', '.git' ]):
    path = os.path.join( base_path, path )
    partial_data_files = []
    for root, dirs, files in os.walk( os.path.join( path )):
        sample_list = []
        for skip_dir in skip_dirs:
            if skip_dir in dirs:
              dirs.remove( skip_dir )
        if files:
            for filename in files:
                sample_list.append( os.path.join( root, filename ))
        if sample_list:
            partial_data_files.append((
                root.replace(
                base_path + os.sep if base_path else '',
                '',
                1
                ),
                sample_list
            ))
    return partial_data_files

opt_includes = ["encodings", "django", "ls"]
opt_excludes = []
dll_excludes = []
packages = []
project_name = "ls"
dist_dir = "setup/" + project_name

opt_py2exe = {
    "compressed":1, 
    "optimize":2,
    "bundle_files":1,
    "dist_dir":dist_dir,
    "packages":packages,
    "excludes":opt_excludes,
    "includes":opt_includes,
    "dll_excludes":dll_excludes,
    }

options = {
    "py2exe":opt_py2exe
    }

# Take the first value from the environment variable PYTHON_PATH
python_path = os.environ[ 'PYTHONPATH' ].split( ';' )[ 0 ]

django_admin_path = os.path.normpath( python_path + '/lib/site-packages/django/contrib/admin' )
py2exe_data_files = []

# django admin files
py2exe_data_files += add_path_tree( django_admin_path, 'templates' )
py2exe_data_files += add_path_tree( django_admin_path, 'media' )

# project files
project_path = "ls"
py2exe_data_files += add_path_tree( project_path, 'data' )
py2exe_data_files += add_path_tree( project_path, 'templates' )
py2exe_data_files += add_path_tree( project_path, 'static_dir' )

setup(
    version="1.0",
    description="django application",
    name="django_app",
    console=[{"script":"run.py", "icon_resources":[(1, "app.ico")]}],
    zipfile=None,
    options=options,
    data_files=py2exe_data_files
    )