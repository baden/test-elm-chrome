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

    lorem = ("Lorem ipsum dolor sit amet, consectetur adipisicing elit,"
    + " sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    + " Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris"
    + " nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in"
    + " reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla"
    + " pariatur. Excepteur sint occaecat cupidatat non proident, sunt in"
    + " culpa qui officia deserunt mollit anim id est laborum.").split(" ");

    function rand_word() {
        var r = Math.random() * lorem.length | 0;
        return lorem[r];
    }

    function rand_verb() {
        return "" + rand_word() + " "
        + rand_word() + " "
        + rand_word() + " "
        + rand_word() + " "
        + rand_word() + " "
        + rand_word() + ".\r";
    }

    function str2ab(str) {
      var buf = new ArrayBuffer(str.length*2); // 2 bytes for each char
      var bufView = new Uint8Array(buf);
      for (var i=0, strLen=str.length; i<strLen; i++) {
        bufView[i] = str.charCodeAt(i);
      }
      return buf;
    }

    var onReceive = {
        addListener : function(callback) {
            var counter = 0;
            var id = setInterval(function(){
                for(var cid in cids) {
                    // console.log("cid=", cid);
                    var data = {
                        connectionId: cid | 0
                        , data : str2ab(rand_verb())
                    };
                    callback(data);
                }
                // counter += 1;
            }, 1000);

        }
    };

    var onReceiveError = {
        addListener : function(callback) {
            // var counter = 0;
            // var id = setInterval(function(){
            //     counter += 1;
            //     var data = {
            //         connectionId: 42
            //         , data : new ArrayBuffer ("test")
            //     };
            //     callback(data);
            // }, 5000);
        }
    };

    var cid = 42;
    var cids = {};

    var connect = function(path, options, callback) {
        var data = {
            connectionId: cid
        };
        cids[cid] = true;
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
