package anzsoft.iJabBar.client.data;

import java.util.List;

import com.extjs.gxt.ui.client.data.BasePagingLoadResult;
import com.extjs.gxt.ui.client.data.ListLoadResult;
import com.extjs.gxt.ui.client.data.PagingLoadConfig;
import com.extjs.gxt.ui.client.data.PagingLoadResult;
import com.extjs.gxt.ui.client.data.ModelData;

/**
 * A <code>XmlReader</code> implementation that reads XML data using a
 * <code>ModelType</code> definition and returns a paging list load result
 * instance.
 * 
 * @param <D> the type of list load result being returned by the reader
 */
public class RosterPagingLoadResultReader<D extends PagingLoadResult<? extends ModelData>>
		extends RosterLoadResultReader<D> {
	/**
	 * Creates a new reader.
	 * 
	 * @param modelType the model type definition
	 */
	public RosterPagingLoadResultReader() {
		super();
	}

	@SuppressWarnings("unchecked")
	@Override
	protected Object createReturnData(Object loadConfig,
			List<ModelData> records, int totalCount) {
		ListLoadResult<?> result = (ListLoadResult<?>) super.createReturnData(
				loadConfig, records, totalCount);

		if (result instanceof PagingLoadResult) {
			PagingLoadResult<?> r = (PagingLoadResult<?>) result;
			r.setTotalLength(totalCount);

			if (loadConfig instanceof PagingLoadConfig) {
				PagingLoadConfig config = (PagingLoadConfig) loadConfig;
				r.setOffset(config.getOffset());
			}
		}
		return result;

	}

	@Override
	protected BasePagingLoadResult<ModelData> newLoadResult(Object loadConfig,
			List<ModelData> models) {
		return new BasePagingLoadResult<ModelData>(models);
	}

}
