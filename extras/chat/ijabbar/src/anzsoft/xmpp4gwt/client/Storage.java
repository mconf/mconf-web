package anzsoft.xmpp4gwt.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.core.client.JavaScriptObject;

public class Storage {
	private static final String GWT_PERSIST_SWF = GWT.getModuleBaseURL()
			+ "persist.swf";

	@SuppressWarnings("unused")
	private final JavaScriptObject delegate;

	public static Storage createStorage(final String name,
			final String storage_prefix) {
		return new Storage(storage_prefix + name);
	}

	private Storage(final String name) {
		delegate = initJSO("XMPP4GwtStorage_" + name, GWT_PERSIST_SWF);
	}

	private native JavaScriptObject initJSO(final String name,
			final String swfPath)
	/*-{
		return   new $wnd.Persist.Store(name, {swf_path: swfPath});
	 }-*/;

	public native String get(final String key)
	/*-{
		try
		{
			var ret = null;
			this.@anzsoft.xmpp4gwt.client.Storage::delegate.get(key,function(ok,value)
			{
				if(ok)
					ret = value;
			});
			return ret;
		}
		catch(e)
		{
			return null;
		}
	 }-*/;

	public native void set(final String key, final String value)
	/*-{
		this.@anzsoft.xmpp4gwt.client.Storage::delegate.set(key,value);
	 }-*/;

	public native void remove(final String key)
	/*-{
		try
		{
	 		this.@anzsoft.xmpp4gwt.client.Storage::delegate.remove(key);
		}
		catch(e)
		{
		}
	 }-*/;

}
