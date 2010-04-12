package org.jivesoftware.openfire.plugin;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.codec.binary.Base64;
import org.dom4j.DocumentException;
import org.dom4j.io.SAXReader;
import org.jivesoftware.util.AlreadyExistsException;
import org.jivesoftware.util.JiveGlobals;
import org.jivesoftware.util.NotFoundException;
import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.openfire.event.SessionEventDispatcher;
import org.jivesoftware.openfire.event.SessionEventListener;
import org.jivesoftware.openfire.muc.ConflictException;
import org.jivesoftware.openfire.muc.ForbiddenException;
import org.jivesoftware.openfire.muc.MUCEventDispatcher;
import org.jivesoftware.openfire.muc.MUCEventListener;
import org.jivesoftware.openfire.muc.MUCRoom;
import org.jivesoftware.openfire.muc.NotAllowedException;
import org.jivesoftware.openfire.session.Session;
import org.jivesoftware.openfire.vcard.VCardManager;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xmpp.packet.JID;
import org.xmpp.packet.Message;
import org.xmpp.packet.Presence;

/**
 * Vcc Rooms Plugin.
 * 
 * @author Diego Moreno
 */
public class VccRoomsPlugin implements Plugin {

	private static final String CONFIG_EVENT_PROFILES_URL   = "plugin.vccRooms.vccEventProfilesUrl";
	private static final String CONFIG_EVENTS_URL           = "plugin.vccRooms.vccEventsUrl";
	private static final String CONFIG_XMPP_SERVER_USER     = "plugin.vccRooms.xmppServerUser";
	private static final String CONFIG_XMPP_SERVER_PASSWORD = "plugin.vccRooms.xmppServerPassword";
	private static final String CONFIG_ADMIN_ROLES          = "plugin.vccRooms.adminRoles";
	private static final String CONFIG_AVATAR_URL           = "plugin.vccRooms.vccAvatarUrl";

	private VccRoomsMUCEventListener mucListener = new VccRoomsMUCEventListener();
	private VccRoomsSessionEventListener mucSessionListener = new VccRoomsSessionEventListener();
	
	private ArrayList<String> adminRoles = new ArrayList<String>();
	
	public void initializePlugin(PluginManager manager, File pluginDirectory) {
		MUCEventDispatcher.addListener(mucListener);
		SessionEventDispatcher.addListener(mucSessionListener);
		
		adminRoles = new ArrayList<String>(Arrays.asList(getProperty(CONFIG_ADMIN_ROLES).split(",")));
	}

	public void destroyPlugin() {
		MUCEventDispatcher.removeListener(mucListener);
		SessionEventDispatcher.removeListener(mucSessionListener);

		mucListener = null;
		mucSessionListener = null;
	}

	private String getProperty(String propertyName) {
		return JiveGlobals.getProperty(propertyName, null);
	}
	
	private class VccRoomsMUCEventListener implements MUCEventListener {

		/**
		 * HashMap with the list of users in this event
		 * key   - user name
		 * value - role in this event 
		 */
		private HashMap<String,String> userList = new HashMap<String,String>();
		
		/**
		 * Event triggered when a new room was created.
		 * 
		 * @param roomJID
		 *            JID of the room that was created.
		 */
		public void roomCreated(JID roomJID) {
			MUCRoom mucRoom = XMPPServer.getInstance()
					.getMultiUserChatManager().getMultiUserChatService(roomJID)
					.getChatRoom(roomJID.getNode());
			try {
				// get event name
				String eventId = roomJID.getNode();
				
				// update user list from VCC
				updateUserList(eventId);
				
				// get user administrator list from VCC
				updateAdmins(mucRoom);
				
				mucRoom.setModerated(true);
				// During configuration room was locked
				// It is necessary to unlock
				mucRoom.unlock(mucRoom.getRole());
			} catch (ForbiddenException e) {
			}
		}

		/**
		 * Event triggered when a new occupant joins a room.
		 * 
		 * @param roomJID
		 *            the JID of the room where the occupant has joined.
		 * @param user
		 *            the JID of the user joining the room.
		 * @param nickname
		 *            nickname of the user in the room.
		 */
		public void occupantJoined(JID roomJID, JID user, String nickname) {
			MUCRoom mucRoom = XMPPServer.getInstance()
					.getMultiUserChatManager().getMultiUserChatService(roomJID)
					.getChatRoom(roomJID.getNode());

			// get user name
			String userName = user.getNode();
			
			// get event name
			String eventId = roomJID.getNode();

			// update user list from VCC
			updateUserList(eventId);
			
			// if administrator -> add owner
			// if normal user -> add member as participant
			// if anonymous -> if public: see and do not touch this
			// if private: kick participant
			Presence presence = null;
			List<Presence> presences = null;
			try {
				updateAdmins(mucRoom);
				
				if ( isMember(userName) && isAdministrator(userName) ) {
					// if is administrator
					presences = mucRoom.addOwner(user.toBareJID(), mucRoom.getRole());
				} else if ( isMember(userName) && !isAdministrator(userName) ) {
					// if is normal user but not a administrator
					mucRoom.addMember(user.toBareJID(), null, mucRoom.getRole());
					presence = mucRoom.addParticipant(user, "all members are participants", mucRoom.getRole());
				} else if ( !isMember(userName) ) {
					// if is not member
					// First pass member to avoid NotAllowedException
					mucRoom.addMember(user.toBareJID(), null, mucRoom.getRole());
					mucRoom.addNone(user.toBareJID(), mucRoom.getRole());
					if (isPublicEvent(eventId)) {
						// See but do not touch this
						presence = mucRoom.addVisitor(user, mucRoom.getRole());
					} else {
						// Kick
						presence = mucRoom.kickOccupant(user, null, "not allowed");
					}
				}
			} catch (ForbiddenException e) {
			} catch (ConflictException e) {
			} catch (NotAllowedException e) {
			}

			// Send new presence packets
			if (presence != null) {
				mucRoom.send(presence);
			}
			if (presences != null) {
				for (Presence p : presences) {
					mucRoom.send(p);
				}
			}
		}

		public void roomDestroyed(JID roomJID) { /*ignore*/ }
		
		public void occupantLeft(JID roomJID, JID user) { /*ignore*/ }

		public void nicknameChanged(JID roomJID, JID user, String oldNickname, String newNickname) { /*ignore*/ }

		public void messageReceived(JID roomJID, JID user, String nickname, Message message) { /*ignore*/ }

		public void roomSubjectChanged(JID roomJID, JID user, String newSubject) { /*ignore*/ }
		
		private void updateAdmins(MUCRoom mucRoom) throws ForbiddenException {
			// Get administrator list from VCC
			ArrayList<String> vccAdminList = new ArrayList<String>();
			for( String userName : userList.keySet() ) {
				if (isAdministrator(userName)) {
					vccAdminList.add(userName);
				}
			}

			// Get administrator list from MUC Room
			ArrayList<String> roomAdminList = new ArrayList<String>(mucRoom.getAdmins());
			
			// Set administrators in chat room
			// VCC - current = administrators to add
			ArrayList<String> adminsToAdd = diffStringArray(vccAdminList, roomAdminList);
			for (String adminUser : adminsToAdd) {
				mucRoom.addOwner(adminUser, mucRoom.getRole());
			}

			// current - VCC = administrators to remove
			ArrayList<String> adminsToRemove = diffStringArray(roomAdminList, vccAdminList);
			try {
				for (String adminUser : adminsToRemove) {
					mucRoom.addMember(adminUser, null, mucRoom.getRole());
					mucRoom.addNone(adminUser, mucRoom.getRole());
				}
			} catch (ConflictException e) {
				e.printStackTrace();
			}
		}
		
		private ArrayList<String> diffStringArray(ArrayList<String> one, ArrayList<String> two) {
			ArrayList<String> resultArray = new ArrayList<String>();
			
			boolean matched = false;
			for(String oneElement : one) {
				
				for(String twoElement : two) {
					if (oneElement.equals(twoElement)) {
						matched = true;
					}
				}
				
				if (!matched) {
					resultArray.add(oneElement);	
				}
				
				matched = false;
			}
			
			return resultArray;
		}
		
		private boolean isAdministrator(String userName) {
			String userRole = userList.get(userName);
			for (String role : adminRoles) {
				if (role.equals(userRole)) {
					return true;
				}
			}
			return false;
		}
		
		private boolean isMember(String userName) {
			String userRole = userList.get(userName);
			return (userRole != null) ? true : false; 
		}
		
		private boolean isPublicEvent(String eventName) {
			boolean isPublic = false;
			
			URLConnection con = openAuthorizedConnection( getProperty(CONFIG_EVENTS_URL) + eventName );

    	    String xmlString = getXmlFromOpenConnection( con );
        	
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder;
			Document doc = null;
			try {
				builder = factory.newDocumentBuilder();
				InputSource is = new InputSource(new StringReader(xmlString));
				
				doc = builder.parse( is );
			} catch (ParserConfigurationException e) {
				e.printStackTrace();
			} catch (SAXException e) { 
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			if (doc != null) {
				Node firstChild = doc.getFirstChild();
				isPublic = Boolean.parseBoolean( getContentOfTag(firstChild, "public") );
			}
	    	
			return isPublic;
		}
		
		private void updateUserList(String eventId) {
			HashMap<String,String> localUserList = new HashMap<String,String>();
			String xmlString = getUserListXML(eventId);
	    	
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder;
			Document doc = null;
			try {
				builder = factory.newDocumentBuilder();
				InputSource is = new InputSource(new StringReader(xmlString));
				
				doc = builder.parse( is );
			} catch (ParserConfigurationException e) {
				e.printStackTrace();
			} catch (SAXException e) { 
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			if (doc != null) {
		    	String userName = null;
		    	String userRole = null;
		    	
				Node performancesNode = doc.getFirstChild();
				NodeList performanceList = ((org.w3c.dom.Element)performancesNode).getElementsByTagName("performance");

				for( int i = 0; i < performanceList.getLength(); i++ ) {
					Node performance = performanceList.item(i);

					org.w3c.dom.Element el = (org.w3c.dom.Element) performance;
		    		
					// process agent tag
		    		Node agentNode = el.getElementsByTagName("agent").item(0);
		    		userName = getContentOfTag(agentNode, "login");
		            
		            // process role tag
		    		Node roleNode = el.getElementsByTagName("role").item(0);
		    		userRole = getContentOfTag(roleNode, "name");	            
		    		
		            // add this user with his/her role
		            if (userName != null && userRole != null) {
		            	localUserList.put(userName, userRole);
		            }
		            userName = null;
		            userRole = null;
				}
				
			}
			
			userList = localUserList;
		}
		
		private String getUserListXML(String eventId) {
			String profilesUrl = getProperty(CONFIG_EVENT_PROFILES_URL);
			profilesUrl = profilesUrl.replaceFirst("\\{event-id\\}", eventId );
			URLConnection con = openAuthorizedConnection( profilesUrl );
			return getXmlFromOpenConnection( con );
		}
		        
		private URLConnection openAuthorizedConnection(String stringUrl) {
		    URL url;
			URLConnection con = null;
			
			try {
				url = new URL( stringUrl );
			
				con = url.openConnection();
		    	
				if ( con != null ) {
					String profileAndPassword = getProperty(CONFIG_XMPP_SERVER_USER) + ":" + getProperty(CONFIG_XMPP_SERVER_PASSWORD);
				    Base64 base64 = new Base64();
				    byte[] encoding = base64.encode(profileAndPassword.getBytes());
				    String authorizationString = "Basic " + new String(encoding);
				    con.addRequestProperty("authorization", authorizationString);
				}
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
				
			return con;	
		}
		
		/**
		 * Return the content of a tag inside a node
		 * <xml>
		 *   <id>3</id>
		 *   <name>lolo</name>
		 * </xml>
		 * if xml node is passed as parameter and the tagName requested is name, returned value will be "lolo".
		 * @param parentNode
		 * @param tagName
		 * @return
		 */
		private String getContentOfTag(Node parentNode, String tagName) {
			org.w3c.dom.Element el = (org.w3c.dom.Element) parentNode;
    		String returnValue = null;
    		
    		NodeList childList = el.getElementsByTagName(tagName);
    		org.w3c.dom.Element childElement = (org.w3c.dom.Element)childList.item(0);

            if (childElement != null ) {
                NodeList textList = childElement.getChildNodes();
                returnValue = ((Node)textList.item(0)).getNodeValue();
            }
            
            return returnValue;
		}
		
	    private String getXmlFromOpenConnection( URLConnection con ) {
		    BufferedReader in;
		    String xml = "";
		    try {
				in = new BufferedReader(new InputStreamReader(con.getInputStream()));
				String line;
			    while ((line = in.readLine()) != null) {
			      if ( !line.startsWith("<?xml") ) {
	    		      xml += line;
			      }
			    }
			} catch (IOException e) { }
			
			return xml;
	    }
	}
	
	public class VccRoomsSessionEventListener implements SessionEventListener {
	    /**
	     * Notification event indicating that a user has authenticated with the server. The
	     * authenticated user is not an anonymous user.
	     *
	     * @param session the authenticated session of a non anonymous user.
	     */
	    public void sessionCreated(Session session) {
	    	JID jid = session.getAddress();
	        
	        String userName = jid.getNode();
	        
	        if (VCardManager.getProvider().loadVCard(userName) == null) {
	        	createVCard(userName);
	        } else {
	        	updateVCard(userName);
	        }
	    	
	    }

	    public void sessionDestroyed(Session session) {	/* ignore */ }

	    public void anonymousSessionCreated(Session session) { /* ignore */ }

	    public void anonymousSessionDestroyed(Session session) { /* ignore */ }

	    public void resourceBound(Session session) { /* ignore */ }
	    
	    private void createVCard(String userName) {
	    	org.dom4j.Element vCardElement = createVCardXML(userName);
	    	try {
				VCardManager.getProvider().createVCard(userName, vCardElement);
			} catch (AlreadyExistsException e) {
			}
	    }
	    
		private void updateVCard(String userName) {
	    	org.dom4j.Element vCardElement = createVCardXML(userName);
	    	try {
				VCardManager.getProvider().updateVCard(userName, vCardElement);
			} catch (NotFoundException e) {
			}
	    }
		
	    private org.dom4j.Element createVCardXML(String userName) {
	    	String binVal = getAvatarBinary(userName);
			String xmlString = "<vCard xmlns=\"vcard-temp\" version=\"2.0\" prodid=\"-//HandGen//NONSGML vGen v1.0//EN\">"
					+ "<PHOTO><TYPE>image/png</TYPE>"
					+ "<BINVAL>" + binVal + "</BINVAL>"
					+ "</PHOTO>"
					+ "</vCard>";
			
			org.dom4j.Element vCardElement = null;
			SAXReader xmlReader = new SAXReader();
			try {
				vCardElement = xmlReader.read(new StringReader(xmlString)).getRootElement();
			} catch (DocumentException e) {
			}
			return vCardElement;
		}
	    
	    private String getAvatarBinary(String userName) {
	    	URLConnection con = null;
	    	try {
	    		// pick the correct userName avatar
	    		String avatarUrl = getProperty(CONFIG_AVATAR_URL);
	    		avatarUrl = avatarUrl.replaceFirst("\\{user-id\\}", userName);
		    	URL url = new URL( avatarUrl );
		    	con = url.openConnection();
			} catch (MalformedURLException e1) {
	    	} catch (IOException e1) { }
	    	
		    byte[] imageByteArray = null;
		    try {
		    	imageByteArray = new byte[con.getInputStream().available()];
		    	con.getInputStream().read(imageByteArray);
			} catch (IOException e) { }

		    Base64 base64 = new Base64();
		    byte[] encoding = base64.encode(imageByteArray);
		    return new String(encoding);
	    }
	}
}
