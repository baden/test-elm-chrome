/*jslint camelcase: false*/
var _baden$test_elm_chrome$Native_Serial = function() {
    // console.log("_baden$test_elm_chrome$Native_Serial");

    function Cons(hd, tl) {
        return { ctor: '::', _0: hd, _1: tl };
    }

    function fromArray(arr) {
        var out = { ctor: '[]' };
        for(var i = arr.length; i--;) {
    		out = Cons(arr[i], out);
    	}
    	return out;
    }


    var getDevices = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        chrome.serial.getDevices(function(ports){
            var elmPorts = ports.map(function(port) {
                return {
                    displayName: port.displayName || "",
                    path: port.path
                };
            });
            callback(_elm_lang$core$Native_Scheduler.succeed(fromArray(elmPorts)));
        });
    });

    var ab2str = function(buf) {
        var u8buf = new Uint8Array(buf);
        // u8buf.forEach(function(c){
        //     console.log("c=", c);
        // });
        // var u8buf_filtered = u8buf.map(function(char){
        //     if((char < 32)||(char > 127)) return 33;
        //     return char;
        // });
        // return String.fromCharCode.apply(null, u8buf_filtered);
        return String.fromCharCode.apply(null, u8buf);
    };

    var lineBuffers = {};

    var waitMessage = function(settings) {
        console.log("+> waitMessage", [settings]);
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            // console.log("open:binding", [callback]);

            chrome.serial.onReceive.addListener(function(info){
                var cid = info.connectionId;
                var as_string = ab2str(info.data);
                console.log("port on receive", [info, as_string]);

                // TODO: Это все нужно вынести в Elm

                lineBuffers[cid] = lineBuffers[cid] || '';
                lineBuffers[cid] += as_string;

                var index;
                while ((index = lineBuffers[cid].indexOf('\r')) >= 0) {
                    var line;
                    if(lineBuffers[cid].substr(0, 1) === '\n') {
                        line = lineBuffers[cid].substr(1, index-1);
                    } else {
                        line = lineBuffers[cid].substr(0, index);
                    }
                    lineBuffers[cid] = lineBuffers[cid].substr(index + 1);

                    if(line.length > 0) {
                		console.log("log", [line]);

                		var uri;
                		try{
                		    uri = decodeURIComponent(escape(line));
                		} catch (e) {
                		    var length = line.length;
                            var i;
                		    uri = "<" + length + " binary[";
                		    if(length <= 48) {
                                for(i=0; i<length; i++) {
                                    uri += " " + ("00" + (line.charCodeAt(i)).toString(16).toUpperCase()).slice(-2);
                                }
                            } else {
                                for(i=0; i<22; i++) {
                                    uri += " " + (" 00" + (line.charCodeAt(i)).toString(16).toUpperCase()).slice(-2);
                                }
                                uri += " ...";
                                for(i=length-22; i<length; i++) {
                                    uri += " " + (" 00" + (line.charCodeAt(i)).toString(16).toUpperCase()).slice(-2);
                                }
                            }
                			uri += " ]>";
                		}
                        // this.onReadLine.dispatch(uri);
                        var data = {id: 1, data: uri};
                        var task = settings.onReceive(data);
                        _elm_lang$core$Native_Scheduler.rawSpawn(task);
                    }
                }

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
            };

        });
    };

    var connect = function (path) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            console.log("connect", path);
            var options = {
                bitrate: 19200,
                ctsFlowControl: false
            };
            chrome.serial.connect(path, options, function(info){
                console.log("connected", [path, info]);
                callback(_elm_lang$core$Native_Scheduler.succeed(info.connectionId));
            });

            return function() {
            };
        });
    };

    return {
        // waitMessage: F2(waitMessage),
        waitMessage: waitMessage,
        getDevices: getDevices,
        connect: connect
        // getDevices: F2(getDevices)
    };

}();

// Как сделать остальное, можно подсмотреть тут:
// https://github.com/elm-lang/websocket/blob/1.0.2/src/Native/WebSocket.js
// https://github.com/elm-lang/websocket/blob/1.0.2/src/WebSocket/LowLevel.elm
