
var _baden$test_elm_chrome$Native_Serial = function() {
    console.log("_baden$test_elm_chrome$Native_Serial");

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

    var getDevices = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
    {
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

    return {
        // loadTime: loadTime
        loadTime: (new window.Date).getTime(),
        addOne: addOne,
        // set: set,
        getDevices: getDevices
    };

}();

// Как сделать остальное, можно подсмотреть тут:
// https://github.com/elm-lang/websocket/blob/1.0.2/src/Native/WebSocket.js
// https://github.com/elm-lang/websocket/blob/1.0.2/src/WebSocket/LowLevel.elm
