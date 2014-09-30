package org.feirlau.dwr;

import java.util.ArrayList;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.feirlau.dwr.reverse.TopicConstants;
import org.feirlau.dwr.reverse.TopicManager;

public class RestCall {
    
    private static final Log log_ = LogFactory.getLog(RestCall.class);
	private static ArrayList<Person> persons= new ArrayList<Person>();
	
	public static String hello(String name) {
		return "Hello, " + name + "!";
	}
	
	public static Person addPerson(String name, int age, String desc) {
		Person p = new Person();
		p.setName(name);
		p.setAge(age);
		p.setDesc(desc);
		persons.add(p);
		return p;
	}
	
	public static ArrayList<Person> getPersons() {
		return persons;
	}
	
	private static RestCall instance;
	public static RestCall getInstance() {
		if(instance == null) {
			instance = new RestCall();
		}
		return instance;
	}
	
	public static String login(String username, String password) {
        return username + ":" + password;
	}
	
	public static boolean logout(String token) {
        return false;
    }
	
	public static boolean sendMessage(String topic, String message) {
	    ArrayList<String> messages = new ArrayList<String>();
	    messages.add(message);
	    TopicManager.getInstance().notify(topic, messages, TopicConstants.CLIENT_ALL);
	    log_.info("sendMessage(" + topic + ", " + message + ")");
	    return true;
	}
	
}
