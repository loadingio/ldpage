var lc, view, ldld, ldcv, page;
lc = {
  list: []
};
view = new ldview({
  root: document.body,
  text: {
    count: function(){
      return lc.list.length;
    }
  },
  handler: {
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
        document.body.scrollTop;
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
        view.get('reset').classList.toggle('d-none', true);
        view.get('fetch').classList.toggle('d-none', false);
        page.reset();
        lc.list = [];
        return view.render();
      }
    }
  }
});
ldld = new ldloader({
  className: 'ldld full'
});
ldcv = new ldcover({
  root: '.ldcv'
});
page = new paginate({
  fetchOnScroll: true,
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
      }()).map(function(){
        return {
          id: Math.random().toString(36).substring(2)
        };
      });
    });
  }
});
page.on('empty', function(){
  return console.log('empty');
});
page.on('finish', function(){
  view.get('reset').classList.toggle('d-none', false);
  view.get('fetch').classList.toggle('d-none', true);
  return ldcv.toggle(true);
});
page.on('fetch', function(it){
    lc.list || (lc.list = []);
  lc.list = it.concat(lc.list || (lc.list = []));
  return view.render();
});