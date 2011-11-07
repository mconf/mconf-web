// let's not clobber the global namespace, shall we
function /*class*/ MconfGraphics() {
}

MconfGraphics.core_flot = function() 
{
    $.jsonp({
	'url': 'https://mconf.org/stats/json/?callback=MconfGraphics.onDataReceived',
//	'url': 'http://localhost:1234/stats/?callback=MconfGraphics.onDataReceived',
	'method': 'GET',
    });
};

MconfGraphics.plotSeries = function(series, div)
{
    var formatSeries = function(json_series) {
	var datapoints = json_series.datapoints;
	var result = { users: [], audio: [], video: [], room: [] };
	for (var idx = 0, end = datapoints.length; idx < end; idx += 1) {
		var timestamp = datapoints[idx].timestamp * 1000;
		var previousIdx = (idx == 0)? 0: idx - 1;
		
		var previousValue = datapoints[previousIdx].value;
		var value = datapoints[idx].value;

		if (value.users_count != previousValue.users_count)
			result.users.push([timestamp, previousValue.users_count]);
	    result.users.push([timestamp, value.users_count]);
	    
		if (value.video_count != previousValue.video_count)
			result.video.push([timestamp, previousValue.video_count]);	    
	    result.video.push([timestamp, value.video_count]);

		if (value.audio_count != previousValue.audio_count)
			result.audio.push([timestamp, previousValue.audio_count]);
	    result.audio.push([timestamp, value.audio_count]);

		if (value.room_count != previousValue.room_count)
			result.room.push([timestamp, previousValue.room_count]);
	    result.room.push([timestamp, value.room_count]);
	}

	return result;
    };
    
    var options = {
	xaxis: {
	    mode: 'time',
	},
	shadowsSize: 0
    };

    var formatted_series = formatSeries(series);

    var plot_data = [{ 
	    data: formatted_series.users,
	    color: 'blue',
	    shadowSize: 0,
	    label: 'Users'}, { 
	    data: formatted_series.video,
	    color: 'green',
	    shadowSize: 0,
	    label: 'Video streams'}, { 
	    data: formatted_series.audio,
	    color: 'red',
	    shadowSize: 0,
	    label: 'Audio streams'}, { 
	    data: formatted_series.room,
	    color: 'yellow',
	    shadowSize: 0,
	    label: 'Open rooms'
	}];
    // $("#placeholder")
    $.plot(div, plot_data, options);    
};

MconfGraphics.onDataReceived = function(data) 
{
    var daily = data.daily, weekly = data.weekly, monthly = data.monthly, annually = data.annually;
    
    MconfGraphics.plotSeries(daily,$('#placeholder_daily'));
    MconfGraphics.plotSeries(weekly,$('#placeholder_weekly'));
    MconfGraphics.plotSeries(monthly,$('#placeholder_monthly'));
    MconfGraphics.plotSeries(annually,$('#placeholder_annually'));
};

MconfGraphics.onErrorReceived = function(object, textStatus) {
    alert(textStatus);
};
