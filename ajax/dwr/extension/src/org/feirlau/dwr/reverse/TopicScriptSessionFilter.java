package org.feirlau.dwr.reverse;

import org.directwebremoting.ScriptSession;
import org.directwebremoting.ScriptSessionFilter;

public class TopicScriptSessionFilter implements ScriptSessionFilter {
    
    private String topic = "";
    public TopicScriptSessionFilter(String topic) {
        this.topic = topic;
    }

    public boolean match(ScriptSession session) {
        boolean matched = false;
        if(topic == null || topic.trim().equals("")) {
            matched = false;
        } else if(session.getAttribute(TopicConstants.TOPICS) != null) {
            String topics = session.getAttribute(TopicConstants.TOPICS).toString();
            String[] topicList = topics.split(",");
            for(String tmpTopic : topicList) {
                if(topic.equals(tmpTopic)) {
                    matched = true;
                    break;
                }
            }
        }
        return matched;
    }

}
