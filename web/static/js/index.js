var lc, ldld, ldcv, prepare;
lc = {
  list: [],
  listAlt: []
};
ldld = new ldloader({
  className: 'ldld full'
});
ldcv = new ldcover({
  root: '.ldcv'
});
prepare = function(o){
  var root, opt, lc, view, page;
  o == null && (o = {});
  root = o.root, opt = o.opt;
  lc = {
    list: []
  };
  view = new ldview({
    initRender: false,
    root: root,
    text: {
      count: function(){
        return lc.list.length;
      }
    },
    handler: {
      finish: function(arg$){
        var node;
        node = arg$.node;
        return node.classList.toggle('d-none', !lc.page.isEnd());
      },
      reset: function(arg$){
        var node;
        node = arg$.node;
        return node.classList.toggle('d-none', !lc.page.isEnd());
      },
      fetch: function(arg$){
        var node;
        node = arg$.node;
        return node.classList.toggle('d-none', lc.page.isEnd());
      },
      item: {
        key: function(it){
          return it.id;
        },
        list: function(){
          return lc.list || [];
        },
        init: function(arg$){
          var node;
          node = arg$.node;
        },
        handler: function(arg$){
          var node, data;
          node = arg$.node, data = arg$.data;
          node.classList.add('active');
          return ld$.find(node, '[ld=id]', 0).innerText = data.id;
        }
      }
    },
    action: {
      click: {
        fetch: function(){
          return page.fetch();
        },
        reset: function(){
          lc.list = [];
          return lc.page.reset().then(function(){
            return view.render();
          });
        }
      }
    }
  });
  lc.page = page = new paginate(import$({
    fetch: function(){
      var this$ = this;
      ldld.on();
      return debounce(1000).then(function(){
        var len;
        ldld.off();
        len = lc.list.length > 2 * this$.limit
          ? 0
          : lc.list.length > 1.47 * this$.limit
            ? Math.round(this$.limit * 0.47)
            : this$.limit;
        return (function(){
          var i$, to$, results$ = [];
          for (i$ = 0, to$ = len; i$ < to$; ++i$) {
            results$.push(i$);
          }
          return results$;
        }()).map(function(it){
          return {
            id: 1 + it + this$.offset
          };
        });
      });
    }
  }, opt));
  page.on('empty', function(){
    return console.log('empty');
  });
  page.on('finish', function(){
    return view.render(['reset', 'fetch', 'finish']);
  });
  page.on('fetch', function(it){
        lc.list || (lc.list = []);
    lc.list = (lc.list || (lc.list = [])).concat(it);
    return view.render();
  });
  return view.render();
};
prepare({
  root: ld$.find("[ld-scope='fetch1']", 0),
  opt: {
    fetchOnScroll: true,
    host: document.scrollingElement
  }
});
prepare({
  root: ld$.find("[ld-scope='fetch2']", 0),
  opt: {
    fetchOnScroll: true,
    pivot: ld$.find("[ld-scope='fetch2'] [ld='pivot']", 0)
  }
});
prepare({
  root: ld$.find("[ld-scope='fetch3']", 0),
  opt: {
    fetchOnScroll: false,
    host: ld$.find("[ld-scope='fetch3'] [ld='host']", 0),
    fetchOnInit: 'lazy'
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}