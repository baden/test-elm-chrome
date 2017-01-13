
var _baden$test_elm_chrome$Native_Serial = function() {
    // console.log("_baden$test_elm_chrome$Native_Serial");

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
        chrome.serial.getDevices(function(ports){
            var elmPorts = ports.map(function(port) {
                var displayName = port.displayName || "";
                return {displayName, path: port.path};
            });
            callback(_elm_lang$core$Native_Scheduler.succeed(fromArray(elmPorts)));
        });
    });

    // var open = function(path, onMessage) {
    //     return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
    //         var serial = chrome.serial;
    //
    //     });
    // }

    var waitMessage = function(settings) {
        console.log("+> waitMessage", [settings]);
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            // console.log("open:binding", [callback]);

            chrome.serial.onReceive.addListener(function(info){
                console.log("port on receive", [info]);
                var data = {id: 1, data: "Fake string"};
                var task = settings.onReceive(data);
                _elm_lang$core$Native_Scheduler.rawSpawn(task);
            });

            chrome.serial.onReceiveError.addListener(function(info){
                console.log("port on receiveError", [info]);
                var data = {id: 2, data: "Fake error string"};
                var task = settings.onReceiveError(data);
                _elm_lang$core$Native_Scheduler.rawSpawn(task);

            });

            // What i must return?
            callback(_elm_lang$core$Native_Scheduler.succeed(42));

            return function() {
                console.log("close");
                // clearInterval(id);
            }

        });
    }

    return {
        // waitMessage: F2(waitMessage),
        waitMessage: waitMessage,
        getDevices: getDevices
        // getDevices: F2(getDevices)
    };

}();

// Как сделать остальное, можно подсмотреть тут:
// https://github.com/elm-lang/websocket/blob/1.0.2/src/Native/WebSocket.js
// https://github.com/elm-lang/websocket/blob/1.0.2/src/WebSocket/LowLevel.elm
