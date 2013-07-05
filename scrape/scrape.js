var page = require('webpage').create();
var url = 'http://pinterest.com/pin/5418462023730672/';
page.open(url,function(status){
	var html = page.content;
	console.log(html);
	phantom.exit();
});

