package anzsoft.iJabBar.client;

import java.util.List;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.RootPanel;
import anzsoft.iJabBar.client.gui.ContactView;
import anzsoft.iJabBar.client.gui.DebugBox;
import anzsoft.iJabBar.client.gui.MainBar;
import anzsoft.iJabBar.client.gui.ContactViewListener;
import anzsoft.iJabBar.client.gui.NotifyBox;
import anzsoft.iJabBar.client.gui.ContactView.RenderMode;
import anzsoft.iJabBar.client.utils.TextUtils;
import anzsoft.xmpp4gwt.client.Bosh2Connector;
import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.SessionListener;
import anzsoft.xmpp4gwt.client.User;
import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;
import anzsoft.xmpp4gwt.client.Session.ServerType;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterItem;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterListener;

public class JabberApp {
	private static JabberApp instance = null;

	public static JabberApp instance() {
		if (instance == null)
			instance = new JabberApp();
		return instance;
	}

	// ui items
	private final MainBar mainBar;
	private final ContactView contactView;

	private final Session session;
	private String httpBind = "http-bind/";
	private String domain = "anzsoft";
	private int priority = 5;
	private String resource = "ijab";
	private String host = null;
	private int port = -1;
	private ServerType serverType = ServerType.EJabberd;
	private boolean debug = false;
	public boolean enableLoginBox = false;
	private RenderMode renderMode;
	public boolean autoLogin = false;
	public String anonymous = "";
	public String autoUser = "";
	public String autoPassword = "";
	public int reconnect_count = 3;

	private String vccSessionCookie = "_vcc_session";
	
	public void addNativeHandler(JavaScriptObject jso) {
		session.addListener(new NativeHandler(jso));
	}

	public JabberApp() {
		//for nurberlin.de test
		//Cookies.setCookie("username", "test1");
		//Cookies.setCookie("SID", "6b40032c665b5a27c732d03954b9b10e");
		//end test 
		initParament();
		this.session = Session.instance();

		this.session.addListener(new SessionListener() {
			public void onBeforeLogin() {
			}

			public void onEndLogin() {
			}

			public void onError(BoshErrorCondition boshErrorCondition,
					String message) {
				if (autoLogin == true && reconnect_count > 0) {
					samespaceLogin();
					reconnect_count--;
				}
			}

			public void onLoginOut() {
			}

		});
		session.getConnector().setHttpBase(httpBind);
		session.setServerType(serverType);
		if (host != null && !(host.length() == 0))
			session.getConnector().setHost(host);
		if (port != -1)
			session.getConnector().setPort(port);

		/*
		Bosh2Connector con = (Bosh2Connector)this.session.getConnector();
		if(con.isCrossDomain())
		{
			con.getScriptSyntaxRquestBuilder().setSendImpl(new ScriptSendImpl()
			{
				public void sendRequest(String body, String url, final String callbackID,
						int timeOut, final ScriptSyntaxRequestCallback callbackHandler) 
				{
					ScriptTagProxy<String> proxy = new ScriptTagProxy<String>(url);
					BaseModelData loadConfig = new BaseModelData();
					loadConfig.set("xml", body);
					proxy.load(null, loadConfig, new AsyncCallback<String>()
					{
						public void onSuccess(String result) 
						{
							GWT.log(result, null);
							callbackHandler.onResponseReceived(callbackID, result);
						}

						public void onFailure(Throwable caught) 
						{
							callbackHandler.onError(callbackID);
						}
						
					});
				}
				
			});
		}
		 */

		contactView = new ContactView();
		contactView.setRenderMode(renderMode);
		mainBar = new MainBar(contactView);

		connectRosterAndUI();

		RootPanel.get().add(mainBar);
		if (debug == true) {
			DebugBox debugBox = new DebugBox((Bosh2Connector) session
					.getConnector());
			RootPanel.get().add(debugBox);
			debugBox.show();
		}
	}

	public void addLeftBarButton(String imgUrl, String tooltip, String url,
			String target) {
		mainBar.addLeftBarButton(imgUrl, tooltip, url, target);
	}

	public MainBar getMainBar() {
		return mainBar;
	}

	private void connectRosterAndUI() {
		RosterListener listener = new RosterListener() {
			public void beforeAddItem(JID jid, String name,
					List<String> groupsNames) {
			}

			public void onAddItem(RosterItem item) {
				contactView.addRosterItem(item);
			}

			public void onEndRosterUpdating() {
			}

			public void onRemoveItem(RosterItem item) {
				contactView.removeRosterItem(item);
			}

			public void onStartRosterUpdating() {
			}

			public void onUpdateItem(RosterItem item) {
				contactView.updateRosterItem(item);
			}

			public void onInitRoster() {
				contactView.onInitRoster();
			}
		};
		session.getRosterPlugin().addRosterListener(listener);
		/*
		
		session.getPresencePlugin().addPresenceListener(new PresenceListener()
		{
			public void beforeSendInitialPresence(Presence presence) 
			{				
			}
			
			public void onContactAvailable(Presence presenceItem) 
			{
				//contactView.updateContactPresence(presenceItem);
			}

			public void onContactUnavailable(Presence presenceItem) 
			{	
				//contactView.updateContactPresence(presenceItem);
			}
			
			public void onPresenceChange(Presence presenceItem) 
			{
				try
				{
					contactView.updateContactPresence(presenceItem);
				}
				catch(Exception e)
				{
					System.out.println(e.toString());
				}
			}

			public void onBigPresenceChanged() 
			{
				contactView.doRefresh();
			}
			
		});
		 */

		contactView.addListener(new ContactViewListener() {
			public void onAuthReq(JID jid) {
			}

			public void onChangeGroup(JID jid, String newGroupName) {
			}

			public void onOpenChat(JID jid) {
			}

			public void onOpenVCard(JID jid) {
			}

			public void onRemoveUser(JID jid) {
			}

			public void onRenameGroup(String oldGroupName, String newGroupName) {
			}

			public void onRenameUser(JID jid, String newName) {
			}

		});
	}

	public void setHttpBind(final String bind) {
		this.httpBind = bind;
	}

	public void setDomain(final String domain) {
		this.domain = domain;
	}

	public void setResource(final String resource) {
		this.resource = resource;
	}

	public void setPriority(int priority) {
		this.priority = priority;
	}

	public void setHost(final String host) {
		this.host = host;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public void setServerType(ServerType type) {
		serverType = type;
	}

	public void setServerTypeByStr(final String str) {
		ServerType type = ServerType.valueOf(str);
		if (type == null)
			setServerType(ServerType.EJabberd);
		else
			setServerType(type);
	}

	public void setRosterRenderMode(final String str) {
		RenderMode mode = RenderMode.valueOf(str);
		if (mode == null)
			renderMode = RenderMode.All;
		else
			renderMode = mode;
	}

	public void samespaceLogin() {
		String userName = Cookies.getCookie(autoUser);//Cookies.getCookie("__ac_name");
		String password = Cookies.getCookie(autoPassword);//Cookies.getCookie("__ac");
		if (userName == null || password == null)
			return;
		userName = userName.replaceAll("\"", "");
		password = password.replaceAll("\"", "");
		if (userName.length() == 0 || password.length() == 0)
			return;
		loginForce(userName, password);
	}

	public void anonymousLogin() {
		if (anonymous.length() == 0)
			return;
		String userName = anonymous + TextUtils.genUniqueId();
		loginForce(userName, userName);
	}

	public void login(final String id, final String password) {
		if (session.isActive()) {
			return;
		} else {
			loginForce(id, password);
		}
	}

	public void loginForce(final String id, final String password) {
		String userName = id;
		String pass = password;
		String hash = "8aa40001b9b39cb257fe646a561a80840c806c55";
		String cookieName = vccSessionCookie;
		if (autoLogin) {
			userName = autoUser;
			pass = hash + "--" + Cookies.getCookie(cookieName);
		}
		if (JabberApp.instance().debug)
			Window.alert(id + " " + pass);
		session.reset();
		User user = session.getUser();
		user.setUsername(userName);
		user.setDomainname(domain);
		user.setPassword(pass);
		user.setResource(resource + TextUtils.genUniqueId());
		user.setPriority(priority);

		session.login();
	}

	public void logout() {
		session.logout();
	}

	public void suspend() {
		session.getPresencePlugin().suspend();
		session.suspend();
		NotifyBox.instance().suspend();
		GlobalHandler.instance().fireOnSuspend();
	}

	public boolean resume() {
		if (!session.resume())
			return false;
		NotifyBox.instance().resume();
		GlobalHandler.instance().fireOnResume();
		return true;
	}

	public Session getSession() {
		return session;
	}

	public ContactView getContactView() {
		return contactView;
	}

	public void talkTo(String jid) {
		if (!session.isActive())
			return;
		if (!jid.contains("@"))
			jid = jid + "@" + session.getDomainName();
		if (contactView.getRenderMode() == RenderMode.Online
				|| contactView.getRenderMode() == RenderMode.None)
			contactView.addRecentContact(jid);
		JID j = JID.fromString(jid);
		mainBar.getChatManager().onOpenChat(j);
	}

	private native void initParament()
	/*-{
		try
		{
			this.@anzsoft.iJabBar.client.JabberApp::httpBind = $wnd.ijab_httpbind;
			this.@anzsoft.iJabBar.client.JabberApp::host = $wnd.ijab_host;
			this.@anzsoft.iJabBar.client.JabberApp::port = $wnd.ijab_port;
			this.@anzsoft.iJabBar.client.JabberApp::domain = $wnd.ijab_domain;
			this.@anzsoft.iJabBar.client.JabberApp::setServerTypeByStr(Ljava/lang/String;)($wnd.ijab_servertype);
			this.@anzsoft.iJabBar.client.JabberApp::setRosterRenderMode(Ljava/lang/String;)($wnd.ijab_rostermode);
			this.@anzsoft.iJabBar.client.JabberApp::debug = $wnd.ijab_debug;
			this.@anzsoft.iJabBar.client.JabberApp::enableLoginBox = $wnd.ijab_enableLoginBox;
			this.@anzsoft.iJabBar.client.JabberApp::autoLogin = $wnd.ijab_autoLogin;
			this.@anzsoft.iJabBar.client.JabberApp::anonymous = $wnd.ijab_anonymous_prefix;
			this.@anzsoft.iJabBar.client.JabberApp::autoUser = $wnd.ijab_auto_user;
			this.@anzsoft.iJabBar.client.JabberApp::autoPassword = $wnd.ijab_auto_password;
			this.@anzsoft.iJabBar.client.JabberApp::reconnect_count = $wnd.ijab_reconnect_count;
			this.@anzsoft.iJabBar.client.JabberApp::vccSessionCookie = $wnd.ijab_vcc_session_cookie;
		}
		catch(e)
		{
		}
	}-*/;
}
