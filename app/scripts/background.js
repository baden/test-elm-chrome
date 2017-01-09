'use strict';

chrome.runtime.onInstalled.addListener(function (details) {
    console.log('previousVersion', details.previousVersion);
});

chrome.app.runtime.onLaunched.addListener(function() {
    chrome.app.window.create('index.html', {
        // id: 'TTY_Logger_Chrome_WindowID',
        // frame: 'none',
        bounds: {
            width: 960,
            height: 600
        },
        // frame: 'none',
        minWidth: 512,
        minHeight: 256
    });
});

chrome.app.window.onClosed.addListener(function() {
    console.log('EXIT===========================');
});

console.log('\'Allo \'Allo! Event Page');
