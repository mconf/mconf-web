package org.jivesoftware.openfire.plugin.vccRooms;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jivesoftware.admin.AuthCheckFilter;
import org.jivesoftware.database.DbConnectionManager;
import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.openfire.plugin.VccRoomsPlugin;
import org.jivesoftware.util.JiveGlobals;

import sun.misc.BASE64Decoder;

public class VccRoomsServlet extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
	
	private VccRoomsPlugin plugin;
	
    private static final String LOAD_HISTORY =
        "SELECT sender, nickname, logTime, subject, body FROM ofMucConversationLog " +
        "WHERE roomID=? AND (nickname IS NOT NULL OR subject IS NOT NULL) ORDER BY logTime";
    private static final String LOAD_ROOMID =
        "SELECT ROOMID FROM OFMUCROOM WHERE NAME=? AND SERVICEID=( SELECT SERVICEID FROM OFMUCSERVICE WHERE SUBDOMAIN=? )";
	
	private static final String CONFIG_VCC_USER = "plugin.vccRooms.vccUser";
	private static final String CONFIG_VCC_PASS = "plugin.vccRooms.vccPass";
    
	private String vccUser;
	private String vccPass;
	private Connection con;
	
    public void init(ServletConfig servletConfig) throws ServletException {
        super.init(servletConfig);
        plugin = (VccRoomsPlugin) XMPPServer.getInstance().getPluginManager().getPlugin("vccrooms");
 
        // Exclude this servlet from requiring the user to login, this servlet has his own authentication system
        AuthCheckFilter.addExclude("vccRooms");
        
        vccUser = JiveGlobals.getProperty(CONFIG_VCC_USER, null);
        vccPass = JiveGlobals.getProperty(CONFIG_VCC_PASS, null);
    }
    
    public void destroy() {
        super.destroy();
        
        if (con != null) DbConnectionManager.closeConnection(con);
        
        // Release the excluded URL
        AuthCheckFilter.removeExclude("vccRooms");
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
    	// Filter by user:password
    	if (!authenticate(request, response)) return;
    	
    	response.setContentType("text/plain");

        // Printwriter for writing out responses to browser
        PrintWriter out = response.getWriter();
    	
    	String eventName = request.getParameter("event-name");

    	if (eventName != null) {
    		//out.println("Event Name: " + eventName + "\n");
    		
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                if ( con == null ) con = DbConnectionManager.getConnection();
            	
            	// Get room id through room name
            	pstmt = con.prepareStatement(LOAD_ROOMID);
            	pstmt.setString(1, eventName);
            	pstmt.setString(2, plugin.getGroupChatServiceName());
            	rs = pstmt.executeQuery();
            	long roomId = -1;
                while (rs.next()) {
                	roomId = rs.getLong(1);
                }
            	
                DbConnectionManager.closeResultSet(rs);
                DbConnectionManager.closeStatement(pstmt);
            	
            	// Get history through room id
                pstmt = con.prepareStatement(LOAD_HISTORY);
                pstmt.setLong(1, roomId);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String senderJID = rs.getString(1);
                    String nickname = rs.getString(2);
                    Date sentDate = new Date(Long.parseLong(rs.getString(3).trim()));
                    String subject = rs.getString(4);
                    String body = rs.getString(5);
                    // Recreate the history only for the rooms that have the conversation logging
                    // enabled
                    //if (room.isLogEnabled()) {
                    //    room.getRoomHistory().addOldMessage(senderJID, nickname, sentDate, subject,
                    //            body);
                    //}
                    out.println("[" + sentDate + "] " + nickname + ": " + body);
                }
                
                DbConnectionManager.closeResultSet(rs);
                DbConnectionManager.closeStatement(pstmt);
            } catch (Exception e) {
            	responseError(response, out);
            }
    	} else {
    		responseError(response, out);
    	}

        out.flush();
    }
    
    private void responseError(HttpServletResponse response, PrintWriter out) {
    	responseError(response, out, null);
    }
    
    private void responseError(HttpServletResponse response, PrintWriter out, String message) {
    	response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		out.print("Error");
		if (message != null) {
			out.println(": " + message);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doGet(request, response);
    }
	
	private boolean authenticate(HttpServletRequest request, HttpServletResponse response) {
	      String userID = null;
	      String password = null;

	      // Assume not valid until proven otherwise

	      boolean valid = false;

	      // Get the Authorization header, if one was supplied

	      String authHeader = request.getHeader("Authorization");
	      if (authHeader != null) {
	         String[] authSplitted = authHeader.split(" ");
	         if (authSplitted.length == 2) {
	        	 String basic = authSplitted[0];
	        	 
	            // We only handle HTTP Basic authentication
				if (basic.equalsIgnoreCase("Basic")) {
					String credentials = authSplitted[1];

					// This example uses sun.misc.* classes.
					// You will need to provide your own
					// if you are not comfortable with that.

					BASE64Decoder decoder = new BASE64Decoder();
					String userPass = "";
					try {
						userPass = new String(decoder.decodeBuffer(credentials));
					} catch (IOException e) {}

	               // The decoded string is in the form
	               // "userID:password".

	               int p = userPass.indexOf(":");
	               if (p != -1) {
	                  userID = userPass.substring(0, p);
	                  password = userPass.substring(p+1);

	                  // Validate user ID and password
	                  // and set valid true true if valid.
	                  // In this example, we simply check
	                  // that neither field is blank

	                  if ((userID.trim().equals(vccUser)) &&
	                      (password.trim().equals(vccPass))) {
	                     valid = true;
	                  }
	               }
				}
	         }
	      }

	      // If the user was not validated, fail with a
	      // 401 status code (UNAUTHORIZED) and
	      // pass back a WWW-Authenticate header for
	      // this servlet.
	      //
	      // Note that this is the normal situation the
	      // first time you access the page.  The client
	      // web browser will prompt for userID and password
	      // and cache them so that it doesn't have to
	      // prompt you again.

	      if (!valid) {
	         //String s = "Basic realm=\"Login Test Servlet Users\"";
	         //response.setHeader("WWW-Authenticate", s);
	         response.setStatus(401);
	      }
	      
	      return valid;
	}
}
