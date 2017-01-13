
var _baden$test_elm_chrome$Native_Serial = function() {
    // console.log("_baden$test_elm_chrome$Native_Serial");

    function loadTime() {
        return 42;
        // (new window.Date).getTime();
    }

    function addOne(x) {
        // console.log("_elm_lang$core$Native_Scheduler=", _elm_lang$core$Native_Scheduler);

        return x+1;
        // (new window.Date).getTime();
    }

    // function set(url) {
    //     return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
    //       var oldIcon = document.getElementById("favicon");
    //       var newIcon = document.createElement("link");
    //       newIcon.id = "favicon";
    //       newIcon.rel = "shortcut icon";
    //       newIcon.href = url;
    //       if (oldIcon) {
    //         document.head.removeChild(oldIcon);
    //       }
    //
    //       document.head.appendChild(newIcon);
    //
    //       callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
    //     });
    // }

    // var Nil = { ctor: '[]' };

    function Cons(hd, tl)
    {
    	return { ctor: '::', _0: hd, _1: tl };
    }

    function fromArray(arr)
    {
    	var out = { ctor: '[]' };
    	for (var i = arr.length; i--; )
    	{
    		out = Cons(arr[i], out);
    	}
    	return out;
    }

    var getDevices = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        // Fake ports for eazy debug
        if(!chrome || !chrome.serial) {
            var elmPorts = [{displayName : "Эмуляция!", path: "/dev/ttyUSB0"}
                , {displayName : "Эмуляция!", path: "/dev/ttyUSB1"}
                , {displayName : "Эмуляция!", path: "/dev/ttyUSB2"}
                , {displayName : "Эмуляция!", path: "/dev/ttyUSB3"}
            ];
            console.log("fake ports=", elmPorts);
            callback(_elm_lang$core$Native_Scheduler.succeed(fromArray(elmPorts)));

            return;
        }
        chrome.serial.getDevices(function(ports){
            console.log("ports=", ports);
            var elmPorts = ports.map(function(port) {
                var displayName = port.displayName || "";
                return {displayName, path: port.path};
            });

            // callback(_elm_lang$core$Native_Scheduler.succeed([Date.now()]));
            callback(_elm_lang$core$Native_Scheduler.succeed(fromArray(elmPorts)));
        });
    });

    // var open = function(path, onMessage) {
    //     return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
    //         var serial = chrome.serial;
    //
    //     });
    // }

    // var serial = chrome.serial;
    var waitMessage = function(settings) {
        console.log("+> waitMessage", [settings]);
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            // console.log("open:binding", [callback]);
            var id = setInterval(function(){
                console.log("Fake Receive Task");
                var data = {id: 42, data: "Fake string"};
                var task = settings.onReceive(data);
                _elm_lang$core$Native_Scheduler.rawSpawn(task);
            }, 10000);

            var id = setInterval(function(){
                // console.log("open:binding:interval", [callback]);
                console.log("Fake ReceiveError Task");
                var data = {id: 42, data: "Fake error string"};
                var task = settings.onReceiveError(data);
                _elm_lang$core$Native_Scheduler.rawSpawn(task);
            }, 20000);

            // TODO
            // socket.addEventListener("close", function(event) {
            // 			_elm_lang$core$Native_Scheduler.rawSpawn(settings.onClose({
            // 				code: event.code,
            // 				reason: event.reason,
            // 				wasClean: event.wasClean
            // 			}));
            // 		});

            callback(_elm_lang$core$Native_Scheduler.succeed(id));

            return function() {
                console.log("close");
                clearInterval(id);
            }

        });
    }



    return {
        // loadTime: loadTime
        loadTime: (new window.Date).getTime(),
        addOne: addOne,
        // waitMessage: F2(waitMessage),
        // waitMessage: F2(waitMessage),
        waitMessage: waitMessage,
        // set: set,
        getDevices: getDevices
        // getDevices: F2(getDevices)
    };

}();

// Как сделать остальное, можно подсмотреть тут:
// https://github.com/elm-lang/websocket/blob/1.0.2/src/Native/WebSocket.js
// https://github.com/elm-lang/websocket/blob/1.0.2/src/WebSocket/LowLevel.elm
