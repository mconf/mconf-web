package anzsoft.iJabBar.client;

import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.widget.Layout;
import com.extjs.gxt.ui.client.widget.layout.AnchorLayout;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.Window.ClosingEvent;
import com.google.gwt.user.client.Window.ClosingHandler;

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class IJabBar implements EntryPoint {

	public void onModuleLoad() {
		@SuppressWarnings("unused")
		Layout junk = new AnchorLayout();

		GXT.init();
		defineBridgeMethod(JabberApp.instance());
		Window.addWindowClosingHandler(new ClosingHandler() {
			public void onWindowClosing(ClosingEvent event) {
				JabberApp.instance().suspend();
			}

		});
		if (!JabberApp.instance().resume()) {
			if (JabberApp.instance().autoLogin) {
				Timer t = new Timer() {
					@Override
					public void run() {
						JabberApp.instance().samespaceLogin();
					}
				};
				t.schedule(2000);
			} else {
				Timer t = new Timer() {
					@Override
					public void run() {
						JabberApp.instance().anonymousLogin();
					}
				};
				t.schedule(2000);
			}
		}
	}

	private native void defineBridgeMethod(JabberApp app)
	/*-{
		$wnd.iJab = 
		{
			login:function(id,password)
			{
				app.@anzsoft.iJabBar.client.JabberApp::login(Ljava/lang/String;Ljava/lang/String;)(id,password);
			},
						
			logout:function()
			{
				app.@anzsoft.iJabBar.client.JabberApp::logout()();
			},
			
			addButton:function(imgUrl,tooltip,url,targe)
			{
				app.@anzsoft.iJabBar.client.JabberApp::addLeftBarButton(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)(imgUrl,tooltip,url,target);
			},
			
			addHandler:function(handler)
			{
				app.@anzsoft.iJabBar.client.JabberApp::addNativeHandler(Lcom/google/gwt/core/client/JavaScriptObject;)(handler);
			},
			
			talkTo:function(jid)
			{
				app.@anzsoft.iJabBar.client.JabberApp::talkTo(Ljava/lang/String;)(jid);
			},
		};
	  }-*/;

}
