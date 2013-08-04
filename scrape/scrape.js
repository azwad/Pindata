var page = require('webpage').create();
var url = 'http://pinterest.com/popular';
page.open(url,function(status){
	var html = page.content;
	console.log(html);
	phantom.exit();
});

