package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.Style.SortDir;
import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.data.ModelData;
import com.extjs.gxt.ui.client.data.PagingLoadResult;
import com.extjs.gxt.ui.client.data.PagingLoader;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.GridEvent;
import com.extjs.gxt.ui.client.event.LiveGridEvent;
import com.extjs.gxt.ui.client.store.ListStore;
import com.extjs.gxt.ui.client.store.StoreEvent;
import com.extjs.gxt.ui.client.store.StoreListener;
import com.extjs.gxt.ui.client.widget.grid.ColumnModel;
import com.extjs.gxt.ui.client.widget.grid.GridView;
import com.google.gwt.dom.client.Element;
import com.google.gwt.user.client.Event;

/**
 * AnzLiveGridView for displaying large amount of data.
 */
public class AnzLiveGridView extends GridView {
	protected El liveScroller;
	protected ListStore<ModelData> liveStore;
	protected int liveStoreOffset = 0;
	protected int totalCount = 0;
	protected int viewIndex;

	private int cacheSize = 200;
	// to prevent flickering
	private boolean isMasked;
	private PagingLoader<PagingLoadResult<ModelData>> loader;
	private int rowHeight = 20;

	@SuppressWarnings("unchecked")
	@Override
	public void handleComponentEvent(GridEvent ge) {
		super.handleComponentEvent(ge);
		int type = ge.getEventTypeInt();
		Element target = ge.getTarget();
		if ((type == Event.ONSCROLL && liveScroller.dom.isOrHasChild(target))
				|| (type == Event.ONMOUSEWHEEL && mainBody.dom
						.isOrHasChild(target))) {
			ge.stopEvent();
			if (type == Event.ONMOUSEWHEEL) {
				int v = ge.getEvent().getMouseWheelVelocityY()
						* getCalculatedRowHeight();
				liveScroller.setScrollTop(liveScroller.getScrollTop() + v);
			} else {
				updateRows(liveScroller.getScrollTop()
						/ getCalculatedRowHeight(), false);
			}
		}
	}

	/**
	 * Sets the height of one row (defaults to 20).
	 * 
	 * @param rowHeight
	 *            the new row height.
	 */
	public void setRowHeight(int rowHeight) {
		this.rowHeight = rowHeight;
	}

	@Override
	protected void afterRender() {
		mainBody.setInnerHtml(renderRows(0, -1));
		renderWidgets(0, -1);
		processRows(0, true);
		applyEmptyText();
	}

	@Override
	protected void calculateVBar(boolean force) {
		if (force) {
			layout();
		}
	}

	protected int getCalculatedRowHeight() {
		return rowHeight + borderWidth;
	}

	protected int getLiveScrollerHeight() {
		return liveScroller.getHeight(true);
	}

	protected int getLiveStoreCalculatedIndex(int index) {
		int calcIndex = index - (cacheSize / 2) + getVisibleRowCount();
		calcIndex = Math.max(0, calcIndex);
		calcIndex = Math.min(totalCount - cacheSize, calcIndex);
		calcIndex = Math.min(index, calcIndex);
		return calcIndex;
	}

	@Override
	protected int getScrollAdjust() {
		return scrollOffset;
	}

	protected int getVisibleRowCount() {
		int rh = getCalculatedRowHeight();
		int visibleHeight = getLiveScrollerHeight();
		return (int) ((visibleHeight < 1) ? 0 : Math
				.floor((double) visibleHeight / rh));
	}

	@SuppressWarnings("unchecked")
	protected void initData(ListStore ds, ColumnModel cm) {
		liveStore = ds;
		super.initData(new ListStore() {
			@Override
			public void sort(String field, SortDir sortDir) {
				AnzLiveGridView.this.liveStore.sort(field, sortDir);
				sortInfo = liveStore.getSortState();
			}

		}, cm);

		loader = (PagingLoader) liveStore.getLoader();
		liveStore.addStoreListener(new StoreListener<ModelData>() {

			public void storeDataChanged(StoreEvent<ModelData> se) {
				liveStoreOffset = loader.getOffset();

				if (totalCount != loader.getTotalCount()) {
					totalCount = loader.getTotalCount();
					int height = (totalCount + 1) * getCalculatedRowHeight();
					// 1000000 as browser maxheight hack
					int count = height / 1000000 + 1;
					int h = height / count;
					StringBuilder sb = new StringBuilder();
					for (int i = 0; i < count; i++) {
						sb.append("<div style=\"height:");
						sb.append(h);
						sb.append("px;\"></div>");
					}
					liveScroller.setInnerHtml(sb.toString());
				}
				updateRows(viewIndex, true);
				if (isMasked) {
					isMasked = false;
					scroller.unmask();
				}

			}
		});
	}

	protected boolean isHorizontalScrollBarShowing() {
		return cm.getTotalWidth() > scroller.getStyleWidth();
	}

	@Override
	protected void onColumnWidthChange(int column, int width) {
		super.onColumnWidthChange(column, width);
		updateRows(viewIndex, false);
	}

	@Override
	protected void renderUI() {
		super.renderUI();
		scroller.setStyleAttribute("overflowY", "hidden");
		liveScroller = grid.el().insertFirst(
				"<div class=\"x-livegrid-scroller\"></div>");

		liveScroller.setTop(mainHd.getHeight());

		liveScroller.addEventsSunk(Event.ONSCROLL);
		mainBody.addEventsSunk(Event.ONMOUSEWHEEL);
	}

	@Override
	protected void resize() {
		int oldCount = getVisibleRowCount();
		super.resize();
		if (mainBody != null) {
			int h = grid.getHeight(true) - mainHd.getHeight(true);
			if (isHorizontalScrollBarShowing()) {
				h -= 19;
			}
			liveScroller.setHeight(h, true);
			scroller.setWidth(grid.getWidth() - getScrollAdjust(), true);

			if (oldCount != getVisibleRowCount()) {
				updateRows(viewIndex, true);
			}
		}
	}

	protected void updateRows(int newIndex, boolean reload) {
		int diff = newIndex - viewIndex;
		int delta = Math.abs(diff);

		// nothing has changed and we are not forcing a reload
		if (delta == 0 && !reload) {
			return;
		}
		int rowCount = getVisibleRowCount();
		viewIndex = Math.min(newIndex, Math.abs(totalCount - rowCount));

		int liveStoreIndex = Math.max(0, viewIndex - liveStoreOffset);

		if (delta > getVisibleRowCount() - 1) {
			reload = true;
		}

		if (reload) {
			delta = diff = getVisibleRowCount();
			ds.removeAll();
		}

		if (delta == 0) {
			return;
		}

		int count = ds.getCount();
		if (diff > 0) {
			// rolling forward
			for (int c = 0; c < delta && c < count; c++) {
				ds.remove(ds.getAt(0));
			}
			count = ds.getCount();
			ds.add(liveStore.getRange(liveStoreIndex + count, liveStoreIndex
					+ count + delta - 1));
		} else {
			// rolling back
			for (int c = 0; c < delta && c < count; c++) {
				ds.remove(ds.getAt(ds.getCount() - 1));
			}

			ds.insert(liveStore.getRange(liveStoreIndex, liveStoreIndex + delta
					- 1), 0);
		}

		LiveGridEvent<ModelData> event = new LiveGridEvent<ModelData>(grid);
		event.setViewIndex(viewIndex);
		event.setPageSize(rowCount);
		event.setTotalCount(totalCount);
		fireEvent(Events.LiveGridViewUpdate, event);
	}

	public void notifyShow() {
		if (liveStore.getCount() == 0 || ds.getCount() != 0)
			return;
		updateRows(0, true);
	}

	public void updateForce() {
		updateRows(0, true);
	}
}
