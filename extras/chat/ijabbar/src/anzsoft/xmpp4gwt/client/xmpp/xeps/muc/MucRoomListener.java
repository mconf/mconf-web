package anzsoft.xmpp4gwt.client.xmpp.xeps.muc;

import java.util.List;

public interface MucRoomListener {
	void onRoomListUpdate(List<MucRoomItem> rooms);
}
