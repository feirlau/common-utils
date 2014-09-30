package org.feirlau.tools.flex;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class FlexManifestAnalyser {

    private static Log log_ = LogFactory.getLog(FlexManifestAnalyser.class);
    
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
    
    
    private static void analysisFlexManifest(String manifest, Map<String, String> components) {
        try {
            File manifestFile = new File(manifest);
            if(!manifestFile.exists()) {
                return;
            }
            FileInputStream in = new FileInputStream(manifestFile);
            Document doc = parse(in);
            in.close();
            NodeList elements = doc.getDocumentElement().getElementsByTagName("component");
            Map<String, String> tmpComponents = new HashMap<String, String>();
            for(int i=0; i<elements.getLength(); i++) {
                Element item = (Element) elements.item(i);
                String compName = item.getAttribute("id");
                String className = item.getAttribute("class");
                if(tmpComponents.containsKey(compName)) {
                    String tmpValue = tmpComponents.get(compName);
                    if(!components.containsKey(tmpValue)) {
                        components.put(tmpValue, compName);
                    }
                    components.put(className, compName);
                    
                } else {
                    tmpComponents.put(compName, className);
                }
            }
        } catch(Exception e) {
            log_.error(e);
        }
    }
    
    private static int maxLength = 0;
    private static Map<String, String> sortComponentsValue(Map<String, String> components) {
        List<Entry<String, String>> list = new ArrayList<Entry<String, String>>(components.entrySet());
        Collections.sort(list, new Comparator<Entry<String, String>>() {
            public int compare(Entry<String, String> o1, Entry<String, String> o2) {
                int tmpResult = o1.getValue().compareTo(o2.getValue());
                if(tmpResult == 0) {
                    tmpResult = o1.getKey().compareTo(o2.getKey());
                }
                return tmpResult;
            }
        });
        Map<String, String> sortedComps = new LinkedHashMap<String, String>();
        for(Iterator<Entry<String, String>> it = list.iterator(); it.hasNext(); ) {
           Entry<String, String> entry = it.next();
           int tmpLength = entry.getValue().length();
           if(tmpLength > maxLength) {
               maxLength = tmpLength;
           }
           sortedComps.put(entry.getKey(), entry.getValue());
        }
        return sortedComps;
    }
    
    private static String wrapSpaces(String str) {
        String tmpResult = "";
        if(null != str) {
            tmpResult = str;
            int tmpLength = maxLength-str.length();
            for(int i=0; i<tmpLength; i++) {
                tmpResult += " ";
            }
        }
        return tmpResult;
    }
    
    private static void storeResult(String outputFile, Map<String, String> components) {
        try {
            File manifestFile = new File(outputFile);
            if(!manifestFile.exists()) {
                manifestFile.createNewFile();
            }
            BufferedWriter buffer = new BufferedWriter(new FileWriter(manifestFile));
            for(Iterator<Entry<String, String>> it = components.entrySet().iterator(); it.hasNext(); ) {
                Entry<String, String> entry = it.next();
                buffer.write(wrapSpaces(entry.getValue()) + " : " + entry.getKey());
                buffer.write("\r\n");
            }
            buffer.flush();
            buffer.close();
        } catch(Exception e) {
            log_.error(e);
        }
    }
    
    public static void main(String[] args) {
        /**
        * For test
        args = new String[]{"D:\\global-manifest.xml", "D:\\components-duplicate.txt"};
        **/
        String globalManifest = args[0];
        String outputFile = args[1];
        Map<String, String> components = new HashMap<String, String>();
        analysisFlexManifest(globalManifest, components);
        components = sortComponentsValue(components);
        storeResult(outputFile, components);
    }
}
