/* jslint laxcomma: true, esversion: 6 */

// var gui = require('nw.gui');
// var win = gui.Window.get();
//
// function showDevTools() {
//   win.showDevTools();
// }


document.addEventListener('DOMContentLoaded', function() {

    let ports = {};

    var app = Elm.Main.init({
        node: document.getElementById('widget'),
        flags: Date.now()
    });

    app.ports.getPort.subscribe(async function(id) {
        // socket.send(message);
        console.log('getPorts', id);

        const port = await navigator.serial.requestPort();
        ports[id] = port;

        console.log('port', port, port.getInfo());
        const vendorId = port.getInfo().usbVendorId.toString(16);
        const productId = port.getInfo().usbProductId.toString(16);
        console.log('vendorId', vendorId);
        console.log('productId', productId);

        app.ports.onPortGeted.send(id);

        // await port.open({ baudRate: 9600 });
    });


      console.log("app", app);

      // var win = gui.Window.get();
      // win.showDevTools();
      // showDevTools();
    });


