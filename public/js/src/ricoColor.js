function attachValueChangeListeners() {
   $('red').onkeypress   = colorChangedDeffered;
   $('green').onkeypress = colorChangedDeffered;
   $('blue').onkeypress  = colorChangedDeffered;
}

function colorChangedDeffered() {
  setTimeout( colorChanged, 1 );
}

function colorChanged() {
   var red   = Math.min( parseInt($('red').value)   || 0, 255);
   var green = Math.min( parseInt($('green').value) || 0, 255);
   var blue  = Math.min( parseInt($('blue').value)  || 0, 255);

   var color = new Rico.Color( red, green, blue );

   var newIllustrateString = "&nbsp;var color = new Rico.Color( ";
   newIllustrateString += red + ", ";
   newIllustrateString += green + ", ";
   newIllustrateString += blue + " ); // color.asHex() = ";
   newIllustrateString += color.asHex();

   $('rgbCode').innerHTML = newIllustrateString;
   $('colorBox').style.backgroundColor = color.asHex();
   //$('colorBox').innerHTML = color.asHex();
}

Rico.includeLoaded('ricoColor.js');
