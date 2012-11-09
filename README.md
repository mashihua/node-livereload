Node-LiveReload
=======

实现[LiveReload](http://livereload.com/)Node.js版本的Server.

当前端开发人员修改了css,javascript,html文件，总是需要能够快速看到修改后的结果。LiveReload能购满足这个需求，当你保存文件时自动刷新页面。

安装：
=======

    npm install -g node-livereload
  
你的浏览器需要安装[LiveReload的扩展](http://help.livereload.com/kb/general-use/browser-extensions)。默认情况下监控当前目录下的下列扩展名的文件：

    'html', 'htm', 'css', 'js', 'png', 'gif', 'jpg','php', 'php5', 'py', 'rb', 'erb'

编程例子：
=======

    livereload = require('livereload');
    livereload.createServer();
    livereload.watch({path : __dirname + "/public});
  
使用express server:

    livereload = require('livereload');
    spawn = require('child_process').spawn;
    express = require('express');  
    app = express();
    app.use('/asset', express.static(__dirname + '/public'));
    livereload = require('livereload');
    livereload.createServer();
    event = livereload.watch({
      exts: ['coffee'],
      path : __dirname + "/public/src"
    });
    event.on('change', function(file){
      spawn('coffee',['-c', '-o', __dirname + '/public/js' , file]);
    });

命令行：
=======

运行`livereload`命令监控当前目录的文件变化并让LiveReload自动刷新你的浏览器。

你可以使用下面命令改变监控目录：
  
    livereload -p /workspace

你也可以添加监控文件的扩展名：

    livereload -e txt,less

文档
=======


* [livereload.coffee](http://mashihua.github.com/node-livereload/docs/livereload.html)
* [server.coffee](http://mashihua.github.com/node-livereload/docs/server.html)
* [watch.coffee](http://mashihua.github.com/node-livereload/docs/watch.html)

单元测试：
========

    打开安装livereload插件的浏览器
    npm test