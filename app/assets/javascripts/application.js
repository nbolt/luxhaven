// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require angular
//= require moment.min
//= require_tree .

$.cookie.json = true

_.mixin({
  rotate: function(array, n, guard) {
    var head, tail
    n = (n == null) || guard ? 1 : n
    n = n % array.length
    tail = array.slice(n)
    head = array.slice(0, n)
    return tail.concat(head)
  }
})

var is_chrome = navigator.userAgent.indexOf('Chrome') > -1; 
var is_explorer = navigator.userAgent.indexOf('MSIE') > -1; 
var is_firefox = navigator.userAgent.indexOf('Firefox') > -1; 
var is_safari = navigator.userAgent.indexOf("Safari") > -1; 
var is_opera = navigator.userAgent.indexOf("Presto") > -1; 
if ((is_chrome)&&(is_safari)) {is_safari=false;}

if (!is_firefox) {
  XMLHttpRequest.prototype.sendAsBinary = function(datastr) {
    var ui8a = new Uint8Array(datastr.length);
    for (var i = 0; i < datastr.length; i++) {
      ui8a[i] = (datastr.charCodeAt(i) & 0xff);
    }
    this.send(ui8a);
  }
}