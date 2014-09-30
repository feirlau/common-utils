package org.feirlau.dwr.servlet;

import java.io.IOException;
import java.util.Set;
import java.util.Map.Entry;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class RestToDwrServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Log logger_ = LogFactory.getLog(RestToDwrServlet.class);
	
	/*
     * (non-Java-doc)
     * 
     * @see javax.servlet.http.HttpServlet#doGet(HttpServletRequest request,
     *      HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (logger_.isDebugEnabled()) {
            logger_.debug("RestToDwrServlet.doGet() RequestURI: " + request.getRequestURI()  +  ", Query: " + request.getQueryString());
        }
        long start = System.currentTimeMillis();
        forward(request, response);
        if (logger_.isDebugEnabled()) {
            logger_.debug("RestToDwrServlet.doGet() time: " + (System.currentTimeMillis() - start) + " ms"  );
        }
    }

    /*
     * (non-Java-doc)
     * 
     * @see javax.servlet.http.HttpServlet#doPost(HttpServletRequest request,
     *      HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (logger_.isDebugEnabled()) {
            logger_.debug("SwfServlet.doPost() RequestURI: " + request.getRequestURI()  +  ", Query: " + request.getQueryString());
        }        
        long start = System.currentTimeMillis();
        forward(request, response);
        if (logger_.isDebugEnabled()) {
            logger_.debug("RestToDwrServlet.doPost() time: " + (System.currentTimeMillis() - start) + " ms"  );
        }
    }
    
    @SuppressWarnings("unchecked")
    protected void forward(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String dwrUrl = "...";
        Set<Entry<String, String>> parameters = request.getParameterMap().entrySet();
        for(Entry<String, String> parameter : parameters) {
            String value = parameter.getValue();
            if(value == null) {
                value = "";
            } else {
                value = value.trim();
            }
            dwrUrl.replaceAll("/${" + parameter.getKey() + "}", parameter.getValue());
        }
        request.getRequestDispatcher(dwrUrl).forward(request, response);
    }
}
