

package org.jivesoftware.openfire.auth;

import org.apache.commons.codec.binary.Base64;
import org.jivesoftware.openfire.user.UserAlreadyExistsException;
import org.jivesoftware.openfire.user.UserManager;
import org.jivesoftware.openfire.user.UserNotFoundException;
import org.jivesoftware.util.JiveGlobals;
import org.jivesoftware.util.Log;
import org.jivesoftware.util.StringUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

/**
 *
 * To enable this provider, set the following in the system properties:
 * <ul>
 * <li><tt>provider.auth.className = org.jivesoftware.openfire.auth.VccCustomAuthProvider</tt></li>
 * </ul>
 *
 * @author Diego Moreno
 */
public class VccCustomAuthProvider implements AuthProvider {

    //private String connectionString;

    private String vccSessionUrl;
    private String userNameHash;
    
    /**
     * Constructs a new VccCustom authentication provider.
     */
    public VccCustomAuthProvider() {
    	String prop1 = "vccCustomAuthProvider.userNameHash";
    	String prop2 = "vccCustomAuthProvider.vccSessionUrl";
    	
        // Convert XML based provider setup to Database based
        JiveGlobals.migrateProperty(prop1);
    	JiveGlobals.migrateProperty(prop2);

        userNameHash  = JiveGlobals.getProperty(prop1);
        vccSessionUrl = JiveGlobals.getProperty(prop2);
        
        if ( userNameHash == null ) {
        	Log.error("System property " + prop1 + "is not set");
        }
        if ( vccSessionUrl == null ) {
        	Log.error("System property " + prop2 + "is not set");
        }
    }

    public void authenticate(String username, String password) throws UnauthorizedException {
        if (username == null || password == null) {
            throw new UnauthorizedException();
        }
        
        String[] result = password.split("--",2);
        if (result.length == 2 && result[0].equals(userNameHash)) {
        	password = result[1];
            // Cookie come in with password parameter.
        	username = cookieVccAuthenticate(password);
        } else {
        	username = restfulVccAuthenticate(username, password);
        }
        
        if (username == null) {
        	throw new UnauthorizedException();
        }

        // Got this far, so the user must be authorized.
        createUser(username);
    }

    public void authenticate(String username, String token, String digest)
            throws UnauthorizedException
    {
    	throw new UnsupportedOperationException();
    }

    public boolean isPlainSupported() {
    	return true;
    }

    public boolean isDigestSupported() {
    	return false;
    }

    public String getPassword(String username) throws UserNotFoundException,
            UnsupportedOperationException
    {
    	throw new UnsupportedOperationException();
    }

    public void setPassword(String username, String password)
            throws UserNotFoundException, UnsupportedOperationException
    {
    	throw new UnsupportedOperationException();
    }

    public boolean supportsPasswordRetrieval() {
    	return false;
    }

    /**
     * Indicates how the password is stored.
     */
    @SuppressWarnings({"UnnecessarySemicolon"})  // Support for QDox Parser
    public enum PasswordType {

        /**
         * The password is stored as plain text.
         */
        plain,

        /**
         * The password is stored as a hex-encoded MD5 hash.
         */
        md5,

        /**
         * The password is stored as a hex-encoded SHA-1 hash.
         */
        sha1;
    }

    /**
     * Checks to see if the user exists; if not, a new user is created.
     *
     * @param username the username.
     */
    private static void createUser(String username) {
        // See if the user exists in the database. If not, automatically create them.
        UserManager userManager = UserManager.getInstance();
        try {
            userManager.getUser(username);
        }
        catch (UserNotFoundException unfe) {
            try {
                Log.debug("VccCustomAuthProvider: Automatically creating new user account for " + username);
                UserManager.getUserProvider().createUser(username, StringUtils.randomString(8),
                        null, null);
            }
            catch (UserAlreadyExistsException uaee) {
                // Ignore.
            }
        }
    }
    
    private String cookieVccAuthenticate(String cookie) {
    	String username = null;
    	
	    URL url;
		URLConnection con = null;
		try {
			url = new URL(vccSessionUrl);
			con = url.openConnection();
		} catch (MalformedURLException e1) {
    	} catch (IOException e1) { }
	   
    	if (con != null) {
    	    String myCookie = "_prueba_session=" + cookie;
    	    con.setRequestProperty("Cookie", myCookie);
    	    
    	    String xml = getXmlFromOpenConnection( con );
    	
    		username = getLoginFromXmlSession( xml );
    	}
    	
    	return username;
    }
    
    private String restfulVccAuthenticate(String username, String password) {
    	String usernameAuthenticated = null;
    	
	    URL url;
		URLConnection con = null;
		try {
			url = new URL("http://chotis.dit.upm.es/vcc/session.xml");
			con = url.openConnection();
	    	
			if ( con != null ) {
				//con.addRequestProperty("Accept", "application/xml");
				
				String profileAndPassword = username + ":" + password;
			    Base64 base64 = new Base64();
			    byte[] encoding = base64.encode(profileAndPassword.getBytes());
			    String authorizationString = "Basic " + new String(encoding);
			    con.addRequestProperty("authorization", authorizationString);
				
	    	    String xml = getXmlFromOpenConnection( con );
	        	
	    	    usernameAuthenticated = getLoginFromXmlSession( xml );				
			}
		} catch (MalformedURLException e1) {
    	} catch (IOException e1) { }

    	return usernameAuthenticated;
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
    
    private String getLoginFromXmlSession( String xml ) {
    	String username = null;
    	
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder;
		Document doc = null;
		try {
			builder = factory.newDocumentBuilder();
			InputSource is = new InputSource(new StringReader(xml));
			
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
			Element el = (Element) firstChild;
			doc.getDocumentElement().normalize();
    		String login = "";
    		
    		NodeList loginList = el.getElementsByTagName("login");
            Element loginElement = (Element)loginList.item(0);

            if (loginElement != null ) {
                NodeList textLoginList = loginElement.getChildNodes();
                login = ((Node)textLoginList.item(0)).getNodeValue();
        		
        		if (login != null && login != "") {
        			username = login;
        		}            	
            }
		}
		
		return username;
    }
}


