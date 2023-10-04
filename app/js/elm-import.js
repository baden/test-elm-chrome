/* jslint laxcomma: true, esversion: 6 */

// var gui = require('nw.gui');
// var win = gui.Window.get();
//
// function showDevTools() {
//   win.showDevTools();
// }


document.addEventListener('DOMContentLoaded', function() {
  var div = document.getElementById('widget');
  Elm.Main.embed(div);

  console.log("----");

  // var win = gui.Window.get();
  // win.showDevTools();
  // showDevTools();
});


