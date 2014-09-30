package org.feirlau.dwr.reverse;

import java.util.ArrayList;

import org.directwebremoting.ScriptSessionFilter;
import org.directwebremoting.ScriptSessions;
import org.directwebremoting.ServerContextFactory;
import org.directwebremoting.extend.TaskDispatcher;
import org.directwebremoting.extend.TaskDispatcherFactory;

public class TopicManagerImpl implements ITopicManager {
    private static TopicManagerImpl instance_;
    public static TopicManagerImpl getInstance() {
        if(instance_ == null) {
            instance_ = new TopicManagerImpl();
        }
        return instance_;
    }
    
    /**
     * Push messages to client which listen on the topic.
     * @param topic, the topic to update.
     * @param messages, the message array to push to client.
     */
    public void notify(String topic, ArrayList<String> messages, int type) {
        if(topic==null || messages==null || messages.size()==0) {
            return;
        }
        if((type & TopicConstants.CLIENT_AS) == TopicConstants.CLIENT_AS) {
            notifyASClient(topic, messages);
        }
        if((type & TopicConstants.CLIENT_JS) == TopicConstants.CLIENT_JS) {
            notifyJSClient(topic, messages);
        }
    }

    public void notifyASClient(String topic, ArrayList<String> messages) {
    }

    public void notifyJSClient(String topic, ArrayList<String> messages) {
        if(topic==null || messages==null || messages.size()==0) {
            return;
        }
        TaskDispatcher taskDispatcher = TaskDispatcherFactory.get(ServerContextFactory.get());
        final ArrayList<TopicMessage> topicMessages = new ArrayList<TopicMessage>();
        TopicMessage topicMessage = new TopicMessage();
        topicMessage.setTopic(topic);
        topicMessage.setMessages(messages);
        topicMessages.add(topicMessage);
        Runnable task = new Runnable() {
            public void run() {
                ScriptSessions.addFunctionCall("dwr.reverse.messageHandler", topicMessages);
            }
        };
        ScriptSessionFilter filter = new TopicScriptSessionFilter(topic);
        taskDispatcher.dispatchTask(filter, task);
    }
    
}