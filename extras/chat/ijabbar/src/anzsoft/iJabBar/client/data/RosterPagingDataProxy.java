package anzsoft.iJabBar.client.data;

import java.util.ArrayList;
import java.util.List;

import anzsoft.xmpp4gwt.client.packet.PacketGwtImpl;

import com.extjs.gxt.ui.client.data.BasePagingLoadConfig;
import com.extjs.gxt.ui.client.data.DataProxy;
import com.extjs.gxt.ui.client.data.DataReader;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.xml.client.Node;
import com.google.gwt.xml.client.NodeList;

public class RosterPagingDataProxy<D> implements DataProxy<D> {

	protected Object data;

	/**
	 * Creates new memory proxy.
	 * 
	 * @param data the local data
	 */
	public RosterPagingDataProxy(Object data) {
		this.data = data;
	}

	/**
	 * Returns the proxy data.
	 * 
	 * @return the data
	 */
	public Object getData() {
		return data;
	}

	@SuppressWarnings("unchecked")
	public void load(DataReader<D> reader, Object loadConfig,
			AsyncCallback<D> callback) {
		try {
			D d = null;
			if (reader != null && data != null) {
				if (data instanceof PacketGwtImpl) {
					PacketGwtImpl packet = (PacketGwtImpl) data;
					BasePagingLoadConfig m = (BasePagingLoadConfig) loadConfig;
					int offset = m.getOffset();
					int limit = m.getLimit();
					int top = offset + limit;
					NodeList all = packet.getElement().getChildNodes();
					if (top > all.getLength())
						top = all.getLength();
					List<Node> nodes = new ArrayList<Node>();
					for (int index = offset; index < top; index++) {
						nodes.add(all.item(index));
					}
					m.set("roster_count", all.getLength());
					d = reader.read(loadConfig, nodes);
				} else
					d = reader.read(loadConfig, data);
			} else {
				d = (D) data;
				if (d instanceof List) {
					d = (D) new ArrayList((List) d);
				}
			}
			callback.onSuccess(d);
		} catch (Exception e) {
			callback.onFailure(e);
		}
	}

	/**
	 * Sets the proxy data.
	 * 
	 * @param data the data
	 */
	public void setData(Object data) {
		this.data = data;
	}
}
