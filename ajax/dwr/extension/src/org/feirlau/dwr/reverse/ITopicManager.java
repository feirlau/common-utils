package org.feirlau.dwr.reverse;

import java.util.ArrayList;

public interface ITopicManager {
    public void notify(String topic, ArrayList<String> messages);
    public void notify(String topic, ArrayList<String> messages, int type);
}
