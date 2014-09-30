package org.feirlau.dwr.reverse;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.directwebremoting.WebContextFactory;
import org.directwebremoting.dwrp.BasePollHandler;
import org.directwebremoting.extend.RealScriptSession;
import org.directwebremoting.extend.RealWebContext;

public class TopicPollHandler extends BasePollHandler {

    public TopicPollHandler() {
        super(true);
    }
    
    public void handle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        super.handle(request, response);
        RealWebContext webContext = (RealWebContext) WebContextFactory.get();
        final RealScriptSession scriptSession = (RealScriptSession) webContext.getScriptSession();
        scriptSession.setAttribute(TopicConstants.TOPICS, request.getHeader(TopicConstants.TOPICS));
    }
    
}