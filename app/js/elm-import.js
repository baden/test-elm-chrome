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

const utf8Decoder = new TextDecoder("utf-8");
let crlfRe = /\r\n|\n|\r/gm;

app.ports.connectPort.subscribe(async function({id, baudrate}) {
    console.log('connectPort', id, baudrate);
    const port = ports[id];
    await port.open({ baudRate: baudrate });

    let chunk = "";

    console.log('TODO: connected', id);
    while (port.readable) {
        const reader = port.readable.getReader();
        let startIndex = 0;
        try {
            while (true) {
                const { value, done } = await reader.read();
                if (done) {
                    // |reader| has been canceled.
                    break;
                }
                chunk = chunk + utf8Decoder.decode(value, { stream: true });
                // console.log(`chunk [${chunk}]`, [chunk]);
                for(;;) {
                    if(!chunk || chunk === '') break;
                    let result = crlfRe.exec(chunk);
                    // console.log(`result [${result}]`, [result]);
                    if(!result) {
                        //console.log(`result [${result}]`, [result]);
                        break;
                        //continue;
                    }
                    let line = chunk.substring(startIndex, result.index);
                    chunk = chunk.substring(result.index + result[0].length);
                    // let line = chunk.substr(0);
                    console.log(`line [${line}]`, [line]);
                    // const timestamp = +new Date();
                    app.ports.onPortReceive.send({id/*, timestamp*/, data: line});
                    break;
                }

                // Do something with |value|…
                // console.log(`UART${id}: [${value}]`);
            }
        } catch (error) {
            // Handle |error|…
            console.log(`UART${id}: error [${error}]`);
        } finally {
            reader.releaseLock();
        }
    }
    console.log('TODO:disconnected', id);
});


console.log("app------------", app);

      // var win = gui.Window.get();
      // win.showDevTools();
      // showDevTools();
});


