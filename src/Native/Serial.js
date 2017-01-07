
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

    var get = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
    {
        chrome.serial.getDevices(function(ports){
            console.log("ports=", ports);
            callback(_elm_lang$core$Native_Scheduler.succeed(Date.now()));
        });
    });

    return {
        // loadTime: loadTime
        loadTime: (new window.Date).getTime(),
        addOne: addOne,
        // set: set,
        get: get
    };

}();


// Elm.Native.Serial = {};
//
// Elm.Native.Serial.make = function(localRuntime) {
//     console.log("WTF", localRuntime);
//   localRuntime.Native = localRuntime.Native || {};
//
//
//   localRuntime.Native.Serial = localRuntime.Native.Serial || {};
//
//   if (localRuntime.Native.Serial.values) {
//     return localRuntime.Native.Serial.values;
//   }
//
//   var Result = Elm.Result.make(localRuntime);
//
//   return localRuntime.Native.Serial.values = {
//     loadTime: (new window.Date).getTime()
//   };
//
// };
