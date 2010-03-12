package anzsoft.iJabBar.client.gui;

import java.util.ArrayList;
import java.util.List;

import anzsoft.iJabBar.client.data.RosterPagingLoadResultReader;

import com.extjs.gxt.ui.client.data.BasePagingLoader;
import com.extjs.gxt.ui.client.data.MemoryProxy;
import com.extjs.gxt.ui.client.data.ModelData;
import com.extjs.gxt.ui.client.data.PagingLoadResult;
import com.extjs.gxt.ui.client.data.PagingLoader;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.GridEvent;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.store.ListStore;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.grid.BufferView;
import com.extjs.gxt.ui.client.widget.grid.ColumnConfig;
import com.extjs.gxt.ui.client.widget.grid.ColumnData;
import com.extjs.gxt.ui.client.widget.grid.ColumnModel;
import com.extjs.gxt.ui.client.widget.grid.Grid;
import com.extjs.gxt.ui.client.widget.grid.GridCellRenderer;
import com.extjs.gxt.ui.client.widget.layout.FitLayout;
import com.extjs.gxt.ui.client.widget.layout.FlowLayout;
import com.extjs.gxt.ui.client.widget.toolbar.FillToolItem;
import com.extjs.gxt.ui.client.widget.toolbar.ToolBar;

public class testGrid extends ContentPanel {
	MemoryProxy<ModelData> proxy;
	//LiveGridView liveView;
	BufferView bufferView;

	public void setData(Object data) {
		proxy.setData(data);
		bufferView.layout();
		//liveView.refresh();
	}

	public testGrid(Object data) {
		FlowLayout layout = new FlowLayout(10);
		setLayout(layout);

		proxy = new MemoryProxy<ModelData>(data);

		RosterPagingLoadResultReader<PagingLoadResult<ModelData>> reader = new RosterPagingLoadResultReader<PagingLoadResult<ModelData>>();

		final PagingLoader<PagingLoadResult<ModelData>> loader = new BasePagingLoader<PagingLoadResult<ModelData>>(
				proxy, reader);

		ListStore<ModelData> store = new ListStore<ModelData>(loader);

		List<ColumnConfig> columns = new ArrayList<ColumnConfig>();

		ColumnConfig title = new ColumnConfig("title", "Topic", 100);
		title.setRenderer(new GridCellRenderer<ModelData>() {

			public Object render(ModelData model, String property,
					ColumnData config, int rowIndex, int colIndex,
					ListStore<ModelData> store, Grid<ModelData> grid) {
				return "<b><a style=\"color: #385F95; text-decoration: none;\" href=\"http://extjs.com/forum/showthread.php?t="
						+ model.get("jid")
						+ "\" target=\"_blank\">"
						+ model.get("name")
						+ "</a></b><br /><a style=\"color: #385F95; text-decoration: none;\" href=\"http://extjs.com/forum/forumdisplay.php?f="
						+ model.get("group")
						+ "\" target=\"_blank\">"
						+ model.get("jid") + " Forum</a>";
			}

		});
		columns.add(title);
		columns.add(new ColumnConfig("replycount", "Replies", 50));

		ColumnConfig last = new ColumnConfig("lastpost", "Last Post", 200);
		last.setRenderer(new GridCellRenderer<ModelData>() {

			public Object render(ModelData model, String property,
					ColumnData config, int rowIndex, int colIndex,
					ListStore<ModelData> store, Grid<ModelData> grid) {
				return model.get("lastpost") + "<br/>by "
						+ model.get("lastposter");
			}

		});
		columns.add(last);

		ColumnModel cm = new ColumnModel(columns);

		Grid<ModelData> grid = new Grid<ModelData>(store, cm);

		bufferView = new BufferView();
		grid.setView(bufferView);

		grid.addListener(Events.Attach, new Listener<GridEvent<ModelData>>() {
			public void handleEvent(GridEvent<ModelData> be) {
				loader.load(0, 500);
			}
		});

		/*
		liveView = new LiveGridView();  
		liveView.setEmptyText("No rows available on the server.");  
		liveView.setRowHeight(32);  
		grid.setView(liveView);  
		 */

		ContentPanel panel = new ContentPanel();
		panel.setFrame(true);
		panel.setCollapsible(true);
		panel.setAnimCollapse(false);
		//panel.setIcon(Resources.ICONS.table());  
		panel.setHeading("LiveGrid Grid");
		panel.setLayout(new FitLayout());
		panel.add(grid);
		panel.setSize(600, 350);

		ToolBar toolBar = new ToolBar();
		toolBar.add(new FillToolItem());

		//LiveToolItem item = new LiveToolItem();  
		//item.bindGrid(grid);  

		//toolBar.add(item);  
		panel.setBottomComponent(toolBar);

		add(panel);
	}

}
