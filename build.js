var NwBuilder = require('nw-builder');
var nw = new NwBuilder({
    files: './dist/**/**', // use the glob format
    // platforms: ['osx32', 'win32', 'win64'],
    platforms: ['linux64'],
    version: '0.19.5'
});

//Log stuff you want

nw.on('log',  console.log);

// Build returns a promise
nw.build().then(function () {
   console.log('all done!');
}).catch(function (error) {
    console.error(error);
});
