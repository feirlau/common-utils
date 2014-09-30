package org.feirlau.dwr.handler;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSON;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.directwebremoting.ConversionException;
import org.directwebremoting.ScriptBuffer;
import org.directwebremoting.extend.ScriptBufferUtil;
import org.directwebremoting.jsonp.JsonpCallHandler;

public class XmlCallHandler extends JsonpCallHandler {
	
	public static final String MIME_XML = "text/xml";
    private static final Log log = LogFactory.getLog(XmlCallHandler.class);
    
    private static ThreadLocal<HttpServletResponse> currentResponse = new ThreadLocal<HttpServletResponse>();
    
    public void handle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        currentResponse.set(response);
        super.handle(request, response);
    }
    
    public void writeData(PrintWriter out, Object data, String callback) {
        try {
            currentResponse.get().setContentType(MIME_XML);
            out.println(createOutput(data, callback));
        } catch (ConversionException ex) {
            log.warn("--ConversionException: class=" + ex.getConversionType().getName(), ex);
            try {
                out.println(createOutput(data, callback));
            } catch (ConversionException ex1) {
                log.error("--Nested ConversionException: Is there an exception handler registered? class=" + ex.getConversionType().getName(), ex);
            }
        }
    }
    
    private String createOutput(Object data, String callback) {
        ScriptBuffer buffer = new ScriptBuffer();
        buffer.appendData(data);
        String output = ScriptBufferUtil.createOutput(buffer, converterManager, true);
        if (data instanceof Exception) {
            output = "{\"error\":" + output + "}";
        }
        if (callback != null && !"".equals(callback.trim())) {
            output = callback + "(" + output + ")";
        }
        XMLSerializer serializer = new XMLSerializer(); 
        JSON json = JSONSerializer.toJSON(output); 
        output = serializer.write(json);
        return output;
    }
}
