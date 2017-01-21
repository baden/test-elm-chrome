/* jslint laxcomma: true, esversion: 6 */

document.addEventListener('DOMContentLoaded', function() {
  var div = document.getElementById('widget');
  Elm.Main.embed(div);
});


// fake chrome.serial for debug

console.log("make fake chrome.serial");
var fakeSerial = (function(){

    var getDevices = function(callback) {
        var ports = [{displayName : "Эмуляция!", path: "/dev/ttyUSB0"}
            , {displayName : "Эмуляция!", path: "/dev/ttyUSB1"}
            , {displayName : "Эмуляция!", path: "/dev/ttyUSB2"}
            , {displayName : "Эмуляция!", path: "/dev/ttyUSB3"}
        ];
        return callback(ports);
    };

    var onReceive = {
        addListener : function(callback) {
            var counter = 0;
            var id = setInterval(function(){
                counter += 1;
                var data = {
                    connectionId: 42
                    , data : new ArrayBuffer ("test")
                };
                callback(data);
            }, 1000);

        }
    };

    var onReceiveError = {
        addListener : function(callback) {
            var counter = 0;
            var id = setInterval(function(){
                counter += 1;
                var data = {
                    connectionId: 42
                    , data : new ArrayBuffer ("test")
                };
                callback(data);
            }, 1500);

        }
    };

    var cid = 42;

    var connect = function(path, options, callback) {
        var data = {
            connectionId: cid
        };
        cid += 1;
        callback(data);
    };

    var disconnect = function(cid, callback) {
        callback(true);
    };

    return {
        getDevices
        , onReceive
        , onReceiveError
        , connect
        , disconnect
    };

})();
chrome.serial = chrome.serial || fakeSerial;
