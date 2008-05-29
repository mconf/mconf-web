function dateIsSpecial(year, month, day) {
    
    var test = SPECIAL_DAYS[year];
    if (!test) return false; //no event for this year
    
    var m = SPECIAL_DAYS[year][month];
    if (!m) return false;
    
    for (var i in m) if (m[i] == day) return true;
    return false;
  };
  
  
  function ourDateStatusFunc(date, y, m, d) {
    if (dateIsSpecial(y, m, d))
      return "special";
    else
      return false; // other dates are enabled
      // return true if you want to disable other dates
  };
  
  
  function dateChanged(calendar) {
    // Beware that this function is called even if the end-user only
    // changed the month/year.  In order to determine if a date was
    // clicked you can use the dateClicked property of the calendar:
    //ENRIQUE I call allways to this function, even if today is clicked or month or year
    //if (calendar.dateClicked) {
      // OK, a date was clicked, redirect to /yyyy/mm/dd/index.php
      var y = calendar.date.getFullYear();	  
      var m = calendar.date.getMonth();     // integer, 0..11
      m = m+1   //it is now from 1..12 as I need (ENRIQUE)
      var d = calendar.date.getDate();      // integer, 1..31
      // redirect...
      //window.location = "?date_start_day=" + y + "-" + m + "-" + d;
	  //new Ajax.Updater('timetable', '/</events/show_calendar?date_start_day=' + y + '-' + m + '-' + d, {asynchronous:true, evalScripts:true}); return false;
    if (calendar.space_id == 0) {
		miloc = '/events/show_calendar?date_start_day=' + y + '-' + m + '-' + d;
	}
	else {
		miloc = "/spaces/" + calendar.space_id + '/events/show_calendar?date_start_day=' + y + '-' + m + '-' + d;
	}
	document.location.href = miloc;
    //}
  };

  
  
function change_table() {
    var y = calendar.date.getFullYear();
    var m = calendar.date.getMonth();     // integer, 0..11
    m = m+1   //it is now from 1..12 as I need (ENRIQUE)
    var d = calendar.date.getDate();      // integer, 1..31
    new Ajax.Updater('timetable', '/events/show_timetable?date_start_day=' + y + '-' + m + '-' + d , {asynchronous:true, evalScripts:true}); return false;
}

function change_table_full(year, month, day) {
    var y = year;
    var m = month;     // integer, 0..11
    var d = day;       // integer, 1..31
    new Ajax.Updater('timetable', '/events/show_timetable?date_start_day=' + y + '-' + m + '-' + d , {asynchronous:true, evalScripts:true, onComplete:calendar.setDate(new Date(month+"/"+day+"/"+year))}); return false;
}