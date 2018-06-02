if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (i in this && this[i] === item)
        return i;
    }
    return -1;
  }
}
window.indexOf = Array.prototype.indexOf;
