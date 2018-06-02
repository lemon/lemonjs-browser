
# files
mkdir -p dist
tmp="dist/tmp.js"
dist_dev="dist/lemon.js"
dist_min="dist/lemon.min.js"

# cleanup old files
if [ -f $tmp ]; then
  rm $tmp
fi
if [ -f $dist_dev ]; then
  rm $dist_dev
fi
if [ -f $dist_min ]; then
  rm $dist_min
fi

# build lemon.js
touch $tmp
cat src/polyfills/index-of.js >> $tmp
cat src/polyfills/object-assign.js >> $tmp
cat src/polyfills/request-animation-frame.js >> $tmp
coffee -c -p -b src/lemon.coffee >> $tmp
coffee -c -p -b src/Component.coffee >> $tmp
coffee -c -p -b src/util/add-class.coffee >> $tmp
coffee -c -p -b src/util/ajax.coffee >> $tmp
coffee -c -p -b src/util/array-observers.coffee >> $tmp
coffee -c -p -b src/util/body-height.coffee >> $tmp
coffee -c -p -b src/util/browser-events.coffee >> $tmp
coffee -c -p -b src/util/check-route.coffee >> $tmp
coffee -c -p -b src/util/check-routes.coffee >> $tmp
coffee -c -p -b src/util/copy.coffee >> $tmp
coffee -c -p -b src/util/define.coffee >> $tmp
coffee -c -p -b src/util/event-handlers.coffee >> $tmp
coffee -c -p -b src/util/get.coffee >> $tmp
coffee -c -p -b src/util/has-class.coffee >> $tmp
coffee -c -p -b src/util/history.coffee >> $tmp
coffee -c -p -b src/util/init.coffee >> $tmp
coffee -c -p -b src/util/load-element.coffee >> $tmp
coffee -c -p -b src/util/offset.coffee >> $tmp
coffee -c -p -b src/util/remove-class.coffee >> $tmp
coffee -c -p -b src/util/route.coffee >> $tmp
coffee -c -p -b src/util/scroll-to.coffee >> $tmp
coffee -c -p -b src/util/toggle-class.coffee >> $tmp
coffee -c -p -b src/util/uid.coffee >> $tmp
coffee -c -p -b src/util/update-dom-element.coffee >> $tmp
coffee -c -p -b src/util/update-page-data.coffee >> $tmp
coffee -c -p -b src/util/window-events.coffee >> $tmp

# dist dev
touch $dist_dev
{
  echo '(function(window) {';
  cat $tmp;
  echo '})(window)';
} > $dist_dev

# dist min
touch $dist_min
cat $dist_dev | uglifyjs -cm > $dist_min

# cleanup tmp
rm $tmp
