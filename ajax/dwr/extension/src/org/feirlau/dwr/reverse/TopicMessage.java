package org.feirlau.dwr.reverse;

import java.util.ArrayList;

public class TopicMessage {
    private String topic = "";
    public String getTopic() {
        return topic;
    }
    public void setTopic(String topic) {
        this.topic = topic;
    }
    
    private ArrayList<String> messages = new ArrayList<String>();
    public ArrayList<String> getMessages() {
        return messages;
    }
    public void setMessages(ArrayList<String> messages) {
        this.messages = messages;
    }
}