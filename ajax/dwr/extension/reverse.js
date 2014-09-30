/**
 * Just include ReverseAjax feature from dwr.engine.
 * Also enrich the reverse ajax feature to support multi topics.
 * @autor feirlau@gmail.com
 */

 /**
 * The DWR object is also defined by dwr.util etc.
 */
if(typeof dwr == 'undefined') dwr = {};

(function() {
  dwr.reverse = {};
  dwr.reverse.topics = new Object()
  /**
   * Register the callback on one topic and the reverse ajax will be started when register.
   * @param topic_id, the topic id to subscribe.
   * @param callback, the listener on the topic, should accept one parameter just like {"topic": "topic_id", "messages": ["message1", "message2"]}.
   **/
  dwr.reverse.register = function(topic_id, callback) {
    if(topic_id == null || callback == null) {
      return;
    }
    var topic = dwr.reverse.topics[topic_id];
    if(topic == null) {
      topic = dwr.reverse.topic.create(topic_id);
      dwr.reverse.topic.addCallback(topic, callback);
      dwr.reverse.topics[topic_id] = topic;
      dwr.reverse.updateTopics();
    } else {
      dwr.reverse.topic.addCallback(topic, callback);
    }
    dwr.reverse.startReverseAjax();
  };
  
  /**
   * Unregister the callback on one topic.
   * @param topic_id, the topic id to unsubscribe.
   * @param callback, the listener on the topic; if null, the whole topic will unsubscribe.
   **/
  dwr.reverse.unregister = function(topic_id, callback) {
    if(topic_id == null) {
      return;
    }
    var topic = dwr.reverse.topics[topic_id];
    if(topic != null) {
      if(callback == null) {
        delete dwr.reverse.topics[topic_id];
        dwr.reverse.updateTopics();
      } else {
        dwr.reverse.topic.removeCallback(topic, callback);
      }
    }
  };
  
  dwr.reverse.topic = {
    create: function(topic_id) {
      var topic = {
        id: topic_id,
        callbacks: [],
        toString: function() {return topic_id;}
      };
      return topic;
    },
    
    addCallback: function(topic, callback) {
      for(var i in topic.callbacks) {
        if(topic.callbacks[i] == callback) {
          return;
        }
      }
      topic.callbacks.push(callback);
    },
    
    removeCallback: function(topic, callback) {
      for(var i in topic.callbacks) {
        if(topic.callbacks[i] == callback) {
          topic.callbacks.splice(i, 1);
          break;
        }
      }
    }
  };
  
  /**
   * When topic changed, need to update the topics attribute and restart the reverse request.
   **/
  dwr.reverse.updateTopics = function() {
    var attributes = {};
    if (dwr.engine._headers) {
      for(var propname in dwr.engine._headers) {
        data = dwr.engine._headers[propname];
        attributes[propname] = data;
      }
    }
    var topicsArray = []
    for(var topic in dwr.reverse.topics) {
      topicsArray.push(topic);
    }
    attributes["topics"] = topicsArray.toString();
    dwr.engine.setHeaders(attributes);
    if(topicsArray.length == 0) {
      dwr.reverse.stopReverseAjax();
    } else if(dwr.engine._activeReverseAjax){
      dwr.reverse.restartReverseAjax();
    };
  };
  
  dwr.reverse.startReverseAjax = function() {
    dwr.engine.setActiveReverseAjax(true);
  };
  /**
   * There are some problems with the default api "dwr.engine.setActiveReverseAjax(false)" to stop the reverse ajax.
   * We need to:
   * 1. Remove the state change handler.
   * 2. Invoke the api to reset the states.
   * 3. Invoke dwr.engine.transport.abort() to remvoe the caches.
   **/
  dwr.reverse.stopReverseAjax = function() {
    for (var batchId in dwr.engine._batches) {
      var batch = dwr.engine._batches[batchId];
      if (batch && batch.req && batch.req==dwr.engine._pollReq) {
        batch.req.onreadystatechange = null;
        dwr.engine.setActiveReverseAjax(false);
        dwr.engine.transport.abort();
        break;
      }
    }
    dwr.engine.setActiveReverseAjax(false);
  };
  dwr.reverse.restartReverseAjax = function() {
    if(dwr.engine._activeReverseAjax) {
      dwr.reverse.stopReverseAjax();
    }
    dwr.reverse.startReverseAjax();
  };
  
  /**
   * Handler on topic updated. Will match the message with each registered topics and invoke its callback.
   * @param messages, the updated message array, and each item is an message object just like {"topic": "topic_id", "messages": ["message1", "message2"]}.
   **/
  dwr.reverse.messageHandler = function(messages) {
    for(var i in messages) {
      var message = messages[i]
      topic = dwr.reverse.topics[message.topic];
      if(topic != null) {
        callbacks = topic.callbacks;
        for(var j in callbacks) {
          var callback = callbacks[j]
          if(typeof callback == "function") {
            callback(message);
          }
        }
      }
    }
  };
})();
 