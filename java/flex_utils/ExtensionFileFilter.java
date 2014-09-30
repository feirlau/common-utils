package org.feirlau.tools.flex;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.List;

public class ExtensionFileFilter implements FileFilter {

    private List<String> extensions;
    public ExtensionFileFilter(String extension) {
        super();
        this.extensions = new ArrayList<String>();
        this.extensions.add(extension);
    }

    public ExtensionFileFilter(List<String> extensions) {
        super();
        this.extensions = extensions;
    }
    
    public boolean accept(File file) {
        if(file.isDirectory() && !file.isHidden()) {
            return true;
        }
        if(extensions == null || extensions.size() == 0) {
            return false;
        }
        String name = file.getName( );
        // find the last
        int index = name.lastIndexOf(".");
        if(index == -1) {
            return false;
        } else if(index == name.length( ) -1) {
            return false;
        } else {
            for(int i=0; i<extensions.size(); i++) {
                String extension = (String)extensions.get(i);
                if(extension.equals(name.substring(index+1))) 
                    return true;
            }
            return false;
        }
    }
}
