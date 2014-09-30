package org.feirlau.tools.flex;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.w3c.dom.Comment;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import org.feirlau.tools.flex.ExtensionFileFilter;

public class FlexManifestHelper {

    private static Log log_ = LogFactory.getLog(FlexManifestHelper.class);
    
    private static String TOKEN_MXML = "mxml";
    private static String TOKEN_METADATA = "metadata";
    private static String TOKEN_BOTH = "both";
    private static String TOKEN_ALL = "all";
    
    private static String TOKEN_REGEXP = "\\[\\s*Manifest\\s*\\(\\s*\"([^\"]+)\"\\s*\\)\\s*\\]";
    
    private static Pattern tokenPattern_ = Pattern.compile(TOKEN_REGEXP);
    
    private static String MANIFEST_XML = "<?xml version=\"1.0\"  encoding=\"UTF-8\"?>" +
    		"<!DOCTYPE map [ <!ELEMENT componentPackage (component*) ><!ELEMENT component EMPTY ><!ATTLIST component id ID #REQUIRED> ]>" +
    		"<componentPackage/>";
    
    private static DocumentBuilderFactory builderFac_ = null;
    
    static {
        try {
            builderFac_ = DocumentBuilderFactory.newInstance();
        } catch(Throwable th) {
            log_.error(th);
        }
    }
    
    public static Document parse(InputStream in) {
        Document doc = null;
        if(in != null) {
            try {
                DocumentBuilder builder = builderFac_.newDocumentBuilder();
                doc = builder.parse(in);
                return doc;
            } catch (Exception e) {
                log_.error(e);
            }
        }
        return doc;
    }
    
    public static void unparse(Document doc, OutputStream out) {
        try {
            OutputFormat format = new OutputFormat(doc);
            format.setLineWidth(180);
            format.setIndenting(true);
            format.setIndent(2);
            XMLSerializer serializer = new XMLSerializer(out, format);
            serializer.serialize(doc);
        } catch(Exception e) {
            log_.error(e);
        }
    }
    
    /**
     * Get all .mxml and .as code list located in source path
     * @param readToken 
     * @param components, the components pair list.
     * @param srcPath, the source path
     * @param packagePath, the soruce package path
     * @param token, the token to generate manifest component.
     * @param readToken, whether read component name by manifest metadata from file.
     */
    public static void getManifestComponents(Map<String, String> components, String srcPath, String packagePath, String token, boolean readToken) {
        if(components == null || srcPath == null || packagePath == null || token == null) {
            return;
        }
        if(!token.equalsIgnoreCase(TOKEN_ALL) && !token.equalsIgnoreCase(TOKEN_BOTH) &&
           !token.equalsIgnoreCase(TOKEN_METADATA) && !token.equalsIgnoreCase(TOKEN_MXML)) {
            return;
        }
        extractManifestComponents(components, srcPath, packagePath, token, readToken);
    }
    
    private static void extractManifestComponents(Map<String, String> components, String rootPath, String currPath, String token, boolean readToken) {
        try {
            File root = new File(rootPath);
            rootPath = root.getAbsolutePath();
            File file = new File(currPath);
            List<String> extenstions = new ArrayList<String>();
            extenstions.add("mxml");
            extenstions.add("as");
            File[] children = file.listFiles(new ExtensionFileFilter(extenstions));
            if(children == null) return;
            for(int i=0; i<children.length; i++) {
                File child = children[i];
                String path = child.getAbsolutePath();
                int startIndex = rootPath.length() + 1;
                String tmpPath = path;
                int endIndex = tmpPath.length();
                if(child.isFile()) {
                    endIndex = path.lastIndexOf(".");
                }
                if(endIndex < startIndex) {
                    endIndex = tmpPath.length();
                }
                tmpPath = path.substring(startIndex, endIndex);
                String[] pathItems = tmpPath.split("[\\\\/]");
                String packageName = null;
                for(int j=0; j<pathItems.length; j++) {
                    if(pathItems[j]!=null && !pathItems[j].trim().equals("")) {
                        if(packageName == null) {
                            packageName = pathItems[j];
                        } else {
                            packageName += "." + pathItems[j];
                        }
                    }
                }
                if(packageName == null || excludeList.contains(packageName)) {
                    log_.debug("the package/class(" + packageName + ") is in the exclude list.");
                    continue;
                }
                if(child.isFile()) {
                    String componentName = getComponentName(path, token, readToken);
                    if(componentName==null || components.containsKey(componentName)) continue;
                    components.put(componentName, packageName);
                } else {
                    extractManifestComponents(components, rootPath, path, token, readToken);
                }
            }
        } catch(Exception e) {
            log_.error(e);
        }
    }
    
    private static String getComponentName(String path, String token, boolean readToken) {
        String componentName = null;
        try {
            boolean tmpFound = false;
            File file = new File(path);
            String[] fileInfo = file.getName().split("\\.");
            if(fileInfo.length != 2) {
                return componentName;
            }
            String fileName = fileInfo[0];
            String fileExt = fileInfo[1];
            if("as".equalsIgnoreCase(fileExt)) {
                if(TOKEN_MXML.equalsIgnoreCase(token)) return componentName;
                if(TOKEN_ALL.equalsIgnoreCase(token)) {
                    tmpFound = true;
                }
                if(TOKEN_METADATA.equalsIgnoreCase(token) || readToken) {
                    BufferedReader buffer = new BufferedReader(new FileReader(file));
                    String line = buffer.readLine();
                    while(line != null) {
                        Matcher matcher = tokenPattern_.matcher(line);
                        if(matcher.find()) {
                            tmpFound = true;
                            componentName = matcher.group(1);
                            break;
                        }
                        line = buffer.readLine();
                    }
                    buffer.close();
                }
            } else if("mxml".equalsIgnoreCase(fileExt)) {
                if(TOKEN_METADATA.equalsIgnoreCase(token)) {
                    tmpFound = false;
                } else {
                    tmpFound = true;
                }
                if(TOKEN_METADATA.equalsIgnoreCase(token) || readToken) {
                    BufferedReader buffer = new BufferedReader(new FileReader(file));
                    String line = buffer.readLine();
                    while(line != null) {
                        Matcher matcher = tokenPattern_.matcher(line);
                        if(matcher.find()) {
                            tmpFound = true;
                            componentName = matcher.group(1);
                            break;
                        }
                        line = buffer.readLine();
                    }
                    buffer.close();
                }
            }
            if(tmpFound && componentName == null) {
                componentName = fileName;
            }
        } catch(Exception e) {
            log_.error(e);
        }
        return componentName;
    }
    
    private static void enrichFlexManifest(String manifest, Map<String, String> components) {
        try {
            File manifestFile = new File(manifest);
            if(!manifestFile.exists()) {
                manifestFile.createNewFile();
                BufferedWriter buffer = new BufferedWriter(new FileWriter(manifestFile));
                buffer.write(MANIFEST_XML);
                buffer.flush();
                buffer.close();
            }
            FileInputStream in = new FileInputStream(manifestFile);
            Document doc = parse(in);
            in.close();
            Element firstItem = null;
            for(Iterator<Entry<String, String>> it = components.entrySet().iterator(); it.hasNext(); ) {
                Entry<String, String> entry = it.next();
                Element preItem = doc.getElementById(entry.getKey());
                if(preItem != null) {
                    String msg = "Ingore same component(" + entry.getValue() + ") in component manifest(" + manifest + ")";
                    log_.warn(msg);
                    continue;
                } else if(!addToGlobalManifest(entry)) {
                    continue;
                }
                Element compItem = doc.createElement("component");
                compItem.setAttribute("id", entry.getKey());
                compItem.setAttribute("class", entry.getValue());
                doc.getDocumentElement().appendChild(compItem);
                if(firstItem == null) firstItem = compItem;
            }
            if(firstItem != null) {
                Comment comment = doc.createComment(" ****** START NEW COMPONENT ****** ");
                doc.getDocumentElement().insertBefore(comment, firstItem);
            }
            FileOutputStream out = new FileOutputStream(manifestFile, false);
            unparse(doc, out);
            out.flush();
            out.close();
        } catch(Exception e) {
            log_.error(e);
        }
    }
    
    private static List<String> excludeList = new ArrayList<String>();
    private static String excludeFile = null;
    private static Document globalDoc = null;
    private static String globalManifest = null;
    private static void initGlobalInfo() {
        if(excludeFile != null) {
            try {
                BufferedReader buffer = new BufferedReader(new FileReader(excludeFile));
                excludeList = new ArrayList<String>();
                String line = buffer.readLine();
                while(line != null) {
                    String[] classes = line.split(";");
                    for(int i=0; i<classes.length; i++) {
                        excludeList.add(classes[i].trim());
                    }
                    line = buffer.readLine();
                }
                buffer.close();
            } catch(Exception e) {
                log_.error(e);
            }
        }
        if(globalManifest != null && globalDoc == null) {
            try {
                File manifestFile = new File(globalManifest);
                if(!manifestFile.exists()) {
                    manifestFile.createNewFile();
                    BufferedWriter buffer = new BufferedWriter(new FileWriter(manifestFile));
                    buffer.write(MANIFEST_XML);
                    buffer.flush();
                    buffer.close();
                }
                FileInputStream in = new FileInputStream(manifestFile);
                globalDoc = parse(in);
                in.close();
            } catch(Exception e) {
                log_.error(e);
            }
        }
    }
    private static void storeGlobalInfo() {
        try {
            if(globalDoc != null) {
                FileOutputStream out = new FileOutputStream(globalManifest, false);
                unparse(globalDoc, out);
                out.flush();
                out.close();
            }
        } catch(Exception e) {
            log_.error(e);
        }
    }
    private static boolean addToGlobalManifest(Entry<String, String> entry) {
        boolean tmpResult = true;
        if(globalDoc != null) {
            Element preItem = globalDoc.getElementById(entry.getKey());
            if(preItem != null) {
                if(preItem.hasAttribute("class") && preItem.getAttribute("class").equals(entry.getValue())) {
                    log_.debug("Ingore same class(" + entry.getValue() + ") in global manifest(" + globalManifest + ")");
                    return tmpResult;
                }
                String msg = "Ingore same component(" + entry.getValue() + ") in global manifest(" + globalManifest + ")";
                log_.warn(msg);
                tmpResult = false;
            }
            Element compItem = globalDoc.createElement("component");
            compItem.setAttribute("id", entry.getKey());
            compItem.setAttribute("class", entry.getValue());
            globalDoc.getDocumentElement().appendChild(compItem);
        }
        return tmpResult;
    }

    private static Map<String, String> sortComponentsValue(Map<String, String> components) {
        List<Entry<String, String>> list = new ArrayList<Entry<String, String>>(components.entrySet());
        Collections.sort(list, new Comparator<Entry<String, String>>() {
            public int compare(Entry<String, String> o1, Entry<String, String> o2) {
                return o1.getValue().compareTo(o2.getValue());
            }
        });
        Map<String, String> sortedComps = new LinkedHashMap<String, String>();
        for(Iterator<Entry<String, String>> it = list.iterator(); it.hasNext(); ) {
           Entry<String, String> entry = it.next();
           sortedComps.put(entry.getKey(), entry.getValue());
        }
        return sortedComps;
    }
    
    private static void printHelp() {
        System.out.println("----------------------------------");
        System.out.println("Need three parameters.");
        System.out.println("First paramter is root path of source codes.");
        System.out.println("Second paramter is packages to be included in manifest file, seperator of list is ';'.");
        System.out.println("Third paramter is path of manifest file.");
        System.out.println("Forth paramter is path of exclude file list.");
        System.out.println("Fifth paramter is the path of global menifest file. ");
        System.out.println("Sixth paramter('mxml'/'metadata'/'both'/'all') is the token to determin to add to menifest file. ");
        System.out.println("Seventh paramter is the flag whether read the manifest token form the file to get the component name. ");
        System.out.println("This command will extract all .mxml and .as files with [Manifest(\"ComponentName\")] under the path list and insert into manifest.xml");
        System.out.println("----------------------------------");
    }
    
    /**
     * @param args
     *  srcPath = "D:\\compc";
     *  packages = "D:\\compc\\org\\feirlau";
     *  manifest = "D:\\compc\\compc-manifest.xml";
     *  excludeFile = "D:\\excludes.txt";
     *  globalManifest = "D:\\global-manifest.xml";
     *  token = "all";
     *  readToken = "false";
     */
    public static void main(String[] args) {
        if(args.length < 7) {
            printHelp();
            return;
        }
        String srcPath;
        String packages;
        String manifest;
        String token = "all";
        boolean readToken = false;
        
        srcPath = args[0].trim();
        packages = args[1].trim();
        if("".equals(packages)) {
            packages = srcPath;
        }
        manifest = args[2].trim();
        if(args.length > 3) {
            excludeFile = args[3].trim();
        }
        if(args.length > 4) {
            globalManifest = args[4].trim();
        }
        if(args.length > 5) {
            token = args[5].trim();
        }
        if(args.length > 6) {
            readToken = Boolean.parseBoolean(args[6].trim());
        }
        String[] packageList = packages.split(";");
        Map<String, String> components = new HashMap<String, String>();
        initGlobalInfo();
        for(int i=0; i<packageList.length; i++) {
            String packageItem = packageList[i];
            if(packageItem != null && !packageItem.trim().equals("")) {
                getManifestComponents(components, srcPath, packageItem, token, readToken);
            }
        }
        components = sortComponentsValue(components);
        enrichFlexManifest(manifest, components);
        storeGlobalInfo();
    }
}
