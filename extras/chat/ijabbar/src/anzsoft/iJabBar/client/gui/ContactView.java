package anzsoft.iJabBar.client.gui;

import java.util.ArrayList;
import java.util.List;

import anzsoft.iJabBar.client.JabberApp;
import anzsoft.iJabBar.client.T;
import anzsoft.iJabBar.client.data.RosterPagingLoadResultReader;
import anzsoft.iJabBar.client.resource.Icons;
import anzsoft.xmpp4gwt.client.Bosh2Connector;
import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.stanzas.Presence;
import anzsoft.xmpp4gwt.client.xmpp.presence.PresenceListener;
import anzsoft.xmpp4gwt.client.xmpp.presence.PresencePlugin;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterItem;

import com.extjs.gxt.ui.client.Style.SelectionMode;
import com.extjs.gxt.ui.client.Style.SortDir;
import com.extjs.gxt.ui.client.data.BaseModelData;
import com.extjs.gxt.ui.client.data.BasePagingLoadConfig;
import com.extjs.gxt.ui.client.data.BasePagingLoader;
import com.extjs.gxt.ui.client.data.LoadEvent;
import com.extjs.gxt.ui.client.data.Loader;
import com.extjs.gxt.ui.client.data.MemoryProxy;
import com.extjs.gxt.ui.client.data.ModelData;
import com.extjs.gxt.ui.client.data.PagingLoadResult;
import com.extjs.gxt.ui.client.data.PagingLoader;
import com.extjs.gxt.ui.client.store.ListStore;
import com.extjs.gxt.ui.client.store.Store;
import com.extjs.gxt.ui.client.store.StoreFilter;
import com.extjs.gxt.ui.client.util.Format;
import com.extjs.gxt.ui.client.util.Params;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.form.TextField;
import com.extjs.gxt.ui.client.widget.grid.ColumnConfig;
import com.extjs.gxt.ui.client.widget.grid.ColumnData;
import com.extjs.gxt.ui.client.widget.grid.ColumnModel;
import com.extjs.gxt.ui.client.widget.grid.Grid;
import com.extjs.gxt.ui.client.widget.grid.GridCellRenderer;
import com.extjs.gxt.ui.client.widget.layout.FitLayout;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.GridEvent;
import com.extjs.gxt.ui.client.event.KeyListener;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.event.LiveGridEvent;
import com.google.gwt.user.client.ui.AbstractImagePrototype;
import com.google.gwt.user.client.ui.Image;

public class ContactView extends ContentPanel implements PresenceListener {
	public static final String JIDID = "jid";
	public static final int DEFAULT_INITIAL_WIDTH = 150;
	private static final String ALIAS = "name";
	public static final String STATUSIMG = "status";
	public static final String STATUSTEXT = "statustext";
	public static final String STATUSVALUE = "statusvalue";

	public enum Status {
		STATUS_OFFLINE, STATUS_DND, STATUS_XA, STATUS_AWAY, STATUS_ONLINE, STATUS_CHAT
	};

	public enum RenderMode {
		All, Online, None
	};

	RenderMode renderMode = RenderMode.All;

	private List<ContactViewListener> listeners = new ArrayList<ContactViewListener>();

	//RosterPagingDataProxy<PagingLoadResult<ModelData>> rosterProxy = null;
	MemoryProxy<PagingLoadResult<ModelData>> rosterProxy = null;
	PagingLoader<PagingLoadResult<ModelData>> rosterLoader = null;
	private ColumnModel gridModel = null;

	private ListStore<ModelData> store;
	private AnzLiveGridView view;
	private Grid<ModelData> grid;
	private int viewIndex = -1;
	private int viewOffset = 0;

	//private testGrid testGrid;
	public ContactView() {
		setBorders(false);
		setHeaderVisible(false);
		this.setId("ijab_contactview");
		setLayout(new FitLayout());
		initView();
		super.add(grid);
		this.setTopComponent(createFilterToolBar());
		Session.instance().getPresencePlugin().addPresenceListener(this);
		/*
		testGrid = new testGrid();
		RootPanel.get().add(testGrid);
		testGrid.show();
		 */
	}

	private void initView() {
		rosterProxy = new MemoryProxy<PagingLoadResult<ModelData>>(null);

		RosterPagingLoadResultReader<PagingLoadResult<ModelData>> reader = new RosterPagingLoadResultReader<PagingLoadResult<ModelData>>();

		rosterLoader = new BasePagingLoader<PagingLoadResult<ModelData>>(
				rosterProxy, reader);
		rosterLoader.setSortDir(SortDir.DESC);

		rosterLoader.addListener(Loader.BeforeLoad, new Listener<LoadEvent>() {
			public void handleEvent(LoadEvent be) {
				BasePagingLoadConfig m = be.<BasePagingLoadConfig> getConfig();
				viewOffset = m.getOffset();
			}
		});

		store = new ListStore<ModelData>(rosterLoader);
		store.setDefaultSort(STATUSVALUE, SortDir.DESC);

		//craete the status column
		ColumnConfig statusImgColumnConfig = new ColumnConfig(STATUSIMG,
				"Status", 20);
		statusImgColumnConfig.setRenderer(new GridCellRenderer<ModelData>() {
			public Object render(ModelData model, String property,
					ColumnData config, int rowIndex, int colIndex,
					ListStore<ModelData> store, Grid<ModelData> grid) {
				Params p = new Params();
				String imageText = model.get(STATUSIMG);
				if (imageText == null || imageText.length() == 0)
					imageText = iconFromStatus(null);
				p.add(imageText);
				return Format.substitute("{0}", p);
			}
		});
		statusImgColumnConfig.setFixed(true);

		ColumnConfig aliasColumnConfig = new ColumnConfig(ALIAS, "Alias", 20);
		aliasColumnConfig.setRenderer(new GridCellRenderer<ModelData>() {
			public Object render(ModelData model, String property,
					ColumnData config, int rowIndex, int colIndex,
					ListStore<ModelData> store, Grid<ModelData> grid) {
				Params p = new Params();
				String name = model.get(ALIAS);
				if (name == null || name.length() == 0) {
					String jid = model.get(JIDID);
					name = JID.fromString(jid).getNode();
				}
				p.add(name);
				String statusText = model.get(STATUSTEXT);
				if (statusText == null || statusText.length() == 0)
					statusText = "";
				else
					statusText = "(" + statusText + ")";
				p.add(statusText);
				return Format
						.substitute(
								"<span style=\"vertical-align: middle;color:black;font-size:12px;\">{0}</span><span style=\"vertical-align: middle;color:gray;font-size:11px;\">{1}</span>",
								p);
			}

		});

		List<ColumnConfig> config = new ArrayList<ColumnConfig>();
		config.add(statusImgColumnConfig);
		config.add(aliasColumnConfig);
		gridModel = new ColumnModel(config);

		view = new AnzLiveGridView();
		//view.setEmptyText("No friends, add now!");
		view.setEmptyText("No friends connected now");
		view.setRowHeight(24);
		view.setForceFit(true);
		view.setAutoFill(true);

		grid = new Grid<ModelData>(store, gridModel);
		grid.setView(view);
		grid.setHideHeaders(true);
		grid.setBorders(false);

		grid.getSelectionModel().setSelectionMode(SelectionMode.SINGLE);
		/*
		grid.addListener(Events.RowDoubleClick , new Listener<GridEvent<ContactData> >()
		{
			public void handleEvent(GridEvent<ContactData> be) 
			{
				List<ContactData> datas = store.getModels();
				ContactData data = datas.get(be.getRowIndex());
				String jid = data.get(JIDID);
				fireOnOpenChat(JID.fromString(jid));
			}
		});
		 */

		grid.addListener(Events.RowClick, new Listener<GridEvent<ModelData>>() {
			public void handleEvent(GridEvent<ModelData> be) {
				List<ModelData> datas = store.getModels();
				ModelData data = datas.get(be.getRowIndex() + viewIndex
						- viewOffset);
				String jid = data.get(JIDID);
				fireOnOpenChat(JID.fromString(jid));
			}

		});

		grid.addListener(Events.CellClick,
				new Listener<GridEvent<ModelData>>() {
					public void handleEvent(GridEvent<ModelData> be) {
						if (be.getColIndex() == 2) {
							List<ModelData> datas = store.getModels();
							ModelData data = datas.get(be.getRowIndex()
									+ viewIndex - viewOffset);
							String jid = data.get(JIDID);
							fireOnOpenVCard(JID.fromString(jid));
						}
					}
				});

		view.addListener(Events.LiveGridViewUpdate,
				new Listener<LiveGridEvent<ModelData>>() {
					public void handleEvent(LiveGridEvent<ModelData> be) {
						viewIndex = be.getViewIndex();
					}

				});
	}

	private String iconFromStatus(final Presence item) {
		final Session session = JabberApp.instance().getSession();
		PresencePlugin plugin = session.getPresencePlugin();
		final Icons icons = Icons.App.getInstance();
		AbstractImagePrototype icon = icons.offline();
		if (item != null
				&& plugin.isAvailableByBareJid(item.getFrom().toStringBare())) {
			switch (item.getShow()) {
			case dnd:
				icon = icons.busy();
			case xa:
				icon = icons.xa();
			case away:
				icon = icons.away();
			case chat:
				icon = icons.chat();
			default:
				icon = icons.online();
			}
		}
		final Image iconImg = new Image();
		icon.applyTo(iconImg);
		return iconImg.toString();
	}

	private ModelData getContactData(final String bareJid) {
		return store.findModel(JIDID, bareJid);
	}

	private void sort() {
		store.sort(STATUSVALUE, SortDir.DESC);
	}

	private void doClear() {
		store.removeAll();
	}

	private void doRefresh() {
		//store.groupBy(USER_GROUP_DD);
		sort();
		doLayoutIfNeeded();
	}

	private void createRosterItem(final RosterItem item) {
		try {
			String statusIcon = iconFromStatus(null);

			String alias = item.getName();
			String status = "";
			if (alias == null || alias.length() == 0) {
				alias = JID.fromString(item.getJid()).getNode();
			}
			final String jid = item.getJid();
			String groups[] = item.getGroups();
			if (item.getGroups().length == 0) {
				groups = new String[1];
				groups[0] = "My Contact";
			}
			String img = null;//JabberApp.instance().getWebAvatarUrl(JID.fromString(item.getJid()));
			if (img == null || img.length() == 0)
				img = "images/default_avatar.png";
			final ModelData data = new BaseModelData();
			data.set(JIDID, jid);
			data.set(ALIAS, alias);
			data.set(STATUSTEXT, status);
			data.set(STATUSIMG, statusIcon);
			data.set(STATUSVALUE, Status.STATUS_OFFLINE.ordinal());
			data.set("group", groups[0]);
			store.add(data);
		} catch (Exception e) {
			System.out.println(e.toString());
		}
	}

	public void onInitRoster() {
		doClear();
		Bosh2Connector con = Session.instance().getBosh2Connector();
		if (con != null)
			con.suspend();
		rosterProxy.setData(Session.instance().getRosterPlugin()
				.getRosterPacket());
		rosterLoader.load();
		if (con != null)
			con.resume();
		doRefresh();
	}

	public void onEndAddRoster() {
		doRefresh();
	}

	public void addRosterItem(final RosterItem item) {
		if (renderMode == RenderMode.None || renderMode == RenderMode.Online)
			return;
		createRosterItem(item);
	}

	public void removeRosterItem(final RosterItem item) {
		ModelData data = getContactData(item.getJid());
		if (data != null) {
			store.remove(data);
		}
	}

	public void updateRosterItem(final RosterItem item) {
		if (renderMode == RenderMode.None)
			return;
		ModelData data = getContactData(item.getJid());
		if (data != null) {
			String alias = item.getName();
			if (alias == null || alias.length() == 0) {
				alias = JID.fromString(item.getJid()).getNode();
			}

			String groups[] = item.getGroups();
			if (item.getGroups().length == 0) {
				groups = new String[1];
				groups[0] = "My Contact";
			}
			data.set(ALIAS, alias);
			//data.set(USER_GROUP_DD, groups[0]);
			store.update(data);
			sort();
			doLayoutIfNeeded();
		} else {
			if (renderMode == RenderMode.All)
				addRosterItem(item);
		}
	}

	private ModelData ensureContactData(final String bareJid) {
		ModelData data = getContactData(bareJid);
		if (data == null) {
			RosterItem rosterItem = Session.instance().getRosterPlugin()
					.getRosterItem(JID.fromString(bareJid));
			if (rosterItem != null) {
				createRosterItem(rosterItem);
				data = getContactData(bareJid);
			}
		}
		return data;
	}

	public void addRecentContact(final String bareJid) {
		ModelData data = ensureContactData(bareJid);
		if (data != null) {
			Presence presence = Session.instance().getPresencePlugin()
					.getPresenceitemByBareJid(bareJid);
			if (presence != null) {
				createContactPresnce(presence);
			}
		}
		doLayoutIfNeeded();
	}

	private void createContactPresnce(final Presence presenceItem) {
		ModelData data = ensureContactData(presenceItem.getFrom()
				.toStringBare());
		if (data != null) {
			String alias = presenceItem.getExtNick();
			if (alias != null && alias.length() == 0) {
				data.set(ALIAS, alias);
			}
			String statusImgStr = iconFromStatus(presenceItem);
			data.set(STATUSIMG, statusImgStr);
			data.set(STATUSVALUE, makeStatus(presenceItem).ordinal());
			data.set(STATUSTEXT, presenceItem.getStatus());

			if (!JabberApp.instance().getSession().IsBigPresence()) {
				store.update(data);
				sort();
			}
		}
	}

	private void updateContactPresence(final Presence presenceItem) {
		if (renderMode == RenderMode.None)
			return;
		createContactPresnce(presenceItem);
	}

	private void doLayoutIfNeeded() {
		if (isRendered()) {
			this.doLayout();
		}
	}

	private Status makeStatus(final Presence presence) {
		if (presence == null)
			return Status.STATUS_OFFLINE;
		final Session session = JabberApp.instance().getSession();
		PresencePlugin plugin = session.getPresencePlugin();
		if (!plugin.isAvailableByBareJid(presence.getFrom().toStringBare()))
			return Status.STATUS_OFFLINE;
		else {
			switch (presence.getShow()) {
			case away:
				return Status.STATUS_AWAY;
			case chat:
				return Status.STATUS_CHAT;
			case dnd:
				return Status.STATUS_DND;
			case xa:
				return Status.STATUS_XA;
			default:
				return Status.STATUS_ONLINE;
			}
		}
	}

	public void addListener(ContactViewListener listener) {
		listeners.add(listener);
	}

	public void removeListener(ContactViewListener listener) {
		listeners.remove(listener);
	}

	private void fireOnOpenChat(final JID j) {
		for (ContactViewListener listener : listeners) {
			listener.onOpenChat(j);
		}
	}

	private void fireOnOpenVCard(final JID j) {
		for (ContactViewListener listener : listeners) {
			listener.onOpenVCard(j);
		}
	}

	private TextField<String> createFilterToolBar() {
		final TextField<String> field = new TextField<String>();
		field.addStyleName("ijab_contactview_searchbox");
		field.setEmptyText(T.t().SearchContact());
		field.setWidth("100%");
		StoreFilter<ModelData> filter = new StoreFilter<ModelData>() {
			@SuppressWarnings("unchecked")
			public boolean select(Store store, ModelData parent,
					ModelData item, String property) {
				String filterText = field.getRawValue();
				String alias = item.get(ALIAS);
				alias = alias == null ? "" : alias;
				String jid = item.get(JIDID);
				if (filterText.length() > 0) {
					if (alias.startsWith(filterText.toLowerCase())
							|| jid.startsWith(filterText.toLowerCase()))
						return true;
					return false;
				} else {
					return true;
				}
			}

		};
		store.addFilter(filter);

		field.addKeyListener(new KeyListener() {
			public void componentKeyPress(ComponentEvent event) {
				if (event.getKeyCode() == 27) {
					store.clearFilters();
					view.updateForce();
					event.stopEvent();
				}
			}

			public void componentKeyUp(ComponentEvent event) {
				if (field.getRawValue().length() > 0) {
					store.applyFilters("");
					view.updateForce();
				} else {
					store.clearFilters();
					view.updateForce();
				}
			}
		});
		return field;
	}

	public void setRenderMode(RenderMode mode) {
		renderMode = mode;
	}

	public RenderMode getRenderMode() {
		return renderMode;
	}

	public void notifyShow() {
		view.notifyShow();
	}

	public void beforeSendInitialPresence(Presence presence) {

	}

	public void onBigPresenceChanged() {
		store.commitChanges();
		doRefresh();
	}

	public void onContactAvailable(Presence presenceItem) {
	}

	public void onContactUnavailable(Presence presenceItem) {

	}

	public void onPresenceChange(Presence presenceItem) {
		try {
			updateContactPresence(presenceItem);
		} catch (Exception e) {
			System.out.println(e.toString());
		}

	}
}
