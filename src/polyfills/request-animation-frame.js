(function(){
  var target_time = 0;
  if (!window.requestAnimationFrame) {
    window.requestAnimationFrame = function(callback) {
      var current_time = +new Date;
      target_time = Math.max(target_time + 16, current_time);
      var timeout_cb = function() { callback(+new Date); }
      return window.setTimeout(timeout_cb, target_time - current_time);
    };
  }
})();
