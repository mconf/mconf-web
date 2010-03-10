package anzsoft.iJabBar.client;

import java.util.ArrayList;
import java.util.List;

public class GlobalHandler {
	private static GlobalHandler _instance = null;

	public static GlobalHandler instance() {
		if (_instance == null)
			_instance = new GlobalHandler();
		return _instance;
	}

	private final List<CacheHandler> cacheHandlers = new ArrayList<CacheHandler>();

	private GlobalHandler() {

	}

	public void fireOnSuspend() {
		for (CacheHandler handler : cacheHandlers) {
			handler.onSuspend();
		}
	}

	public void fireOnResume() {
		for (CacheHandler handler : cacheHandlers) {
			handler.onResume();
		}
	}

	public void addCacheHandler(CacheHandler handler) {
		cacheHandlers.add(handler);
	}

	public void removeCacheHandler(CacheHandler handler) {
		cacheHandlers.remove(handler);
	}

}
