package anzsoft.iJabBar.client.data;

import java.util.ArrayList;
import java.util.List;

import anzsoft.xmpp4gwt.client.packet.PacketGwtImpl;
import anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl;

import com.extjs.gxt.ui.client.core.DomQuery;
import com.extjs.gxt.ui.client.data.BaseModelData;
import com.extjs.gxt.ui.client.data.BasePagingLoadConfig;
import com.extjs.gxt.ui.client.data.DataReader;
import com.extjs.gxt.ui.client.data.ModelData;
import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.xml.client.Element;
import com.google.gwt.xml.client.Node;
import com.google.gwt.xml.client.NodeList;

/**
 * A <code>DataReader</code> implementation that reads XML data using a
 * <code>ModelType</code> definition and produces a set of
 * <code>ModelData</code> instances.
 * 
 * <p />
 * Subclasses can override {@link #createReturnData(Object, List, int)} to
 * control what object is returned by the reader. Subclass may override
 * {@link #newModelInstance()} to return any model data subclass.
 * 
 * <p />
 * <code><pre>
 *  // defines the xml structure
 *  ModelType type = new ModelType();
 *  type.setRecordName("record"); // The repeated element which contains row information
 *  type.setRoot("records"); // the optional root element that contains the total attribute (optional)
 *  type.setTotalName("total"); // The element which contains the total dataset size (optional)
 * </pre></code>
 * 
 * @param <D> the type of data being returned by the reader
 */
public class RosterReader<D> implements DataReader<D> {
	/**
	 * Creates a new xml reader instance.
	 * 
	 * @param modelType the model type
	 */
	public RosterReader() {
	}

	private ArrayList<ModelData> recordsFromNodeList(NodeList list) {
		ArrayList<ModelData> records = new ArrayList<ModelData>();
		for (int i = 0; i < list.getLength(); i++) {
			Node node = list.item(i);
			Element elem = (Element) node;
			ModelData model = newModelInstance();

			//get the jid 
			String jid = elem.getAttribute("jid");
			if (jid == null || jid.length() == 0)
				continue;
			model.set("jid", jid);
			String name = elem.getAttribute("name");
			if (name != null)
				model.set("name", name);
			String subscription = elem.getAttribute("subscription");
			if (subscription != null)
				model.set("subscription", subscription);
			String ask = elem.getAttribute("ask");
			if (ask != null)
				model.set("ask", ask);
			String order = elem.getAttribute("order");
			if (order != null)
				model.set("order", order);
			String group = getValue(elem, "group");
			if (group != null)
				model.set("group", group);

			records.add(model);
		}
		return records;
	}

	private ArrayList<ModelData> recordsFromString(String data) {
		ArrayList<ModelData> records = new ArrayList<ModelData>();
		REXML rexml = new REXML(data);
		for (int index = 0; index < rexml.getChildLength(); index++) {
			ModelData model = newModelInstance();
			//get the jid 
			String jid = rexml.getChildAttribute(index, "jid");
			if (jid == null || jid.length() == 0)
				continue;
			model.set("jid", jid);
			String name = rexml.getChildAttribute(index, "name");
			if (name != null)
				model.set("name", name);
			String subscription = rexml
					.getChildAttribute(index, "subscription");
			if (subscription != null)
				model.set("subscription", subscription);
			String ask = rexml.getChildAttribute(index, "ask");
			if (ask != null)
				model.set("ask", ask);
			String order = rexml.getChildAttribute(index, "order");
			if (order != null)
				model.set("order", order);
			String group = rexml.getChildSubNodeValue(index, "group");
			if (group != null)
				model.set("group", group);

			records.add(model);
		}
		return records;
	}

	private ArrayList<ModelData> recordsFromREXML(final JavaScriptObject data) {
		ArrayList<ModelData> records = new ArrayList<ModelData>();
		REXML rexml = new REXML(data);
		for (int index = 0; index < rexml.getChildLength(); index++) {
			ModelData model = newModelInstance();
			//get the jid 
			String jid = rexml.getChildAttribute(index, "jid");
			if (jid == null || jid.length() == 0)
				continue;
			model.set("jid", jid);
			String name = rexml.getChildAttribute(index, "name");
			if (name != null)
				model.set("name", name);
			String subscription = rexml
					.getChildAttribute(index, "subscription");
			if (subscription != null)
				model.set("subscription", subscription);
			String ask = rexml.getChildAttribute(index, "ask");
			if (ask != null)
				model.set("ask", ask);
			String order = rexml.getChildAttribute(index, "order");
			if (order != null)
				model.set("order", order);
			String group = rexml.getChildSubNodeValue(index, "group");
			if (group != null)
				model.set("group", group);

			records.add(model);
		}
		return records;
	}

	@SuppressWarnings("unchecked")
	public D read(Object loadConfig, Object data) {
		NodeList list = null;
		ArrayList<ModelData> records = new ArrayList<ModelData>();
		int totalCount = 0;
		if (data instanceof PacketREXMLImpl) {
			PacketREXMLImpl query = (PacketREXMLImpl) data;
			records = recordsFromREXML(query.getJSO());
			totalCount = records.size();
		} else if (data instanceof PacketGwtImpl) {
			PacketGwtImpl query = (PacketGwtImpl) data;
			list = query.getElement().getElementsByTagName("item");
			records = recordsFromNodeList(list);
			totalCount = records.size();
		} else if (data instanceof String) {
			records = recordsFromString((String) data);
			totalCount = records.size();
		} else if (data instanceof List<?>) {
			List<Node> nodeList = (ArrayList<Node>) data;
			for (int i = 0; i < nodeList.size(); i++) {
				Node node = nodeList.get(i);
				Element elem = (Element) node;
				ModelData model = newModelInstance();

				//get the jid 
				String jid = elem.getAttribute("jid");
				if (jid == null || jid.length() == 0)
					continue;
				model.set("jid", jid);
				String name = elem.getAttribute("name");
				if (name != null)
					model.set("name", name);
				String subscription = elem.getAttribute("subscription");
				if (subscription != null)
					model.set("subscription", subscription);
				String ask = elem.getAttribute("ask");
				if (ask != null)
					model.set("ask", ask);
				String order = elem.getAttribute("order");
				if (order != null)
					model.set("order", order);
				String group = getValue(elem, "group");
				if (group != null)
					model.set("group", group);

				records.add(model);
			}
			BasePagingLoadConfig m = (BasePagingLoadConfig) loadConfig;

			totalCount = m.get("roster_count");
		}
		return (D) createReturnData(loadConfig, records, totalCount);
	}

	/**
	 * Responsible for the object being returned by the reader.
	 * 
	 * @param loadConfig the load config
	 * @param records the list of models
	 * @param totalCount the total count
	 * @return the data to be returned by the reader
	 */
	@SuppressWarnings("unchecked")
	protected Object createReturnData(Object loadConfig,
			List<ModelData> records, int totalCount) {
		return (D) records;
	}

	protected native JavaScriptObject getJsObject(Element elem) /*-{
																return elem.@com.google.gwt.xml.client.impl.DOMItem::getJsObject()();
																}-*/;

	protected String getValue(Element elem, String name) {
		return DomQuery.selectValue(name, getJsObject(elem));
	}

	/**
	 * Returns the new model instances. Subclasses may override to provide a model
	 * data subclass.
	 * 
	 * @return the new model data instance
	 */
	protected ModelData newModelInstance() {
		return new BaseModelData();
	}

}
