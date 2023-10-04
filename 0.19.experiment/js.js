console.log('js.js');


var app = Elm.Main.init({
  node: document.getElementById('myapp'),
  flags: Date.now()
});

navigator.serial.addEventListener("connect", (e) => {
  // Connect to `e.target` or add it to a list of available ports.
  console.log('connect', e);
  app.ports.onPortConnected.send("TDP");
});

navigator.serial.addEventListener("disconnect", (e) => {
  // Remove `e.target` from the list of available ports.
  console.log('disconnect', e);
  app.ports.onPortDisconnected.send("TDP");
});

navigator.serial.getPorts().then((ports) => {
  // Initialize the list of available ports with `ports` on page load.
  console.log('getPorts', ports);
  ports.forEach(port => {
    console.log('port', port, port.getInfo());
    app.ports.onPortFound.send(port.getInfo().usbVendorId + ':' + port.getInfo().usbProductId);
  });
});




app.ports.getPorts.subscribe(async function(message) {
  // socket.send(message);
  console.log('getPorts', message);

  const port = await navigator.serial.requestPort();
  console.log('port', port, port.getInfo());
  const vendorId = port.getInfo().usbVendorId.toString(16);
  const productId = port.getInfo().usbProductId.toString(16);
  console.log('vendorId', vendorId);
  console.log('productId', productId);


  // await port.open({ baudRate: 9600 });
});
