package org.feirlau.dwr.reverse;

import java.util.ArrayList;

import org.directwebremoting.ScriptSessionFilter;
import org.directwebremoting.ScriptSessions;
import org.directwebremoting.ServerContextFactory;
import org.directwebremoting.extend.TaskDispatcher;
import org.directwebremoting.extend.TaskDispatcherFactory;

public class TopicManager implements ITopicManager {
    private static TopicManager instance_;
    public static TopicManager getInstance() {
        if(instance_ == null) {
            instance_ = new TopicManager();
        }
        return instance_;
    }
    
    /**
     * Push messages to client which listen on the topic.
     * @param topic, the topic to update.
     * @param messages, the message array to push to client.
     */
    public void notify(String topic, ArrayList<String> messages) {
        notify(topic, messages, TopicConstants.CLIENT_ALL);
    }
    
    /**
     * Push messages to client which listen on the topic.
     * @param topic, the topic to update.
     * @param messages, the message array to push to client.
     * @param type, the client type, the messages will be published to.
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

    protected void notifyASClient(String topic, ArrayList<String> messages) {
        // Need flex blazeds
        /**
        try {
            if(topic==null || messages==null || messages.size()==0) {
                return;
            }
            MessageBroker msgBroker = MessageBroker.getMessageBroker(null);
            AsyncMessage msg = new AsyncMessage();
            msg.setDestination(REST_MESSAGE_DESTINATION);
            msg.setMessageId(UUIDUtils.createUUID(false));
            msg.setTimestamp(System.currentTimeMillis());
            List<TopicMessage> topicMessages = new ArrayList<TopicMessage>();
            TopicMessage topicMessage = new TopicMessage();
            topicMessage.setTopic(topic);
            topicMessage.setMessages(messages);
            topicMessages.add(topicMessage);
            msg.setBody(topicMessages);
            // header allows consumer to filter message using selector
            msg.setHeader(TopicConstants.TOPIC, topic);
            msgBroker.routeMessageToService(msg, null);
        } catch (Exception ex) {
            logger_.error("[blazedsSynchronize] ", ex);
        }
        */
    }

    protected void notifyJSClient(String topic, ArrayList<String> messages) {
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