ldPage = (opt = {}) ->
  if opt.fetch => @_fetch = opt.fetch; delete opt.fetch
  @ <<< {
    evt-handler: {}, data: {},
    handle: {}, offset: 0, running: false, end: false
  }
  @opt = {
    boundary: 0, limit: 20, scroll-delay: 100, fetch-delay: 200, fetch-on-scroll: false
  } <<< opt
  @limit = @opt.limit # expect user to use this directly.
  if @opt.host => @set-host that
  @

ldPage.prototype = Object.create(Object.prototype) <<< do
  # should be overwritten
  _fetch: -> new Promise (res, rej) -> return res {payload: []}
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  init: (opt = {}) ->
    for k,v of @handle => clearTimeout v
    @ <<< offset: 0, end: false
    if opt.data => @data = opt.data
  is-end: -> @end
  set-host: (host) ->
    if !host or host in [window,document,document.body] => host = document.scrollingElement
    f = (e) ~> @on-scroll e
    if @host => @host.removeEventListener \scroll, f
    @host = (if typeof(host) == \string => document.querySelector(host) else host)
    if !@host => @host = null; return
    if @opt.fetch-on-scroll and !@opt.pivot => return @host.addEventListener \scroll, f
    if @obs => @obs.unobserve @opt.pivot
    update = (ns) ~>
      if !( ns.map(->it.isIntersecting).filter(->it).length and !(@end or @running) ) => return
      @fetch!then ~> @fire \scroll.fetch, it
    @obs = new IntersectionObserver update, {}
    @obs.observe @opt.pivot

  on-scroll: ->
    if @running or @end => return
    clearTimeout @handle.scroll
    @handle.scroll = setTimeout (~>
      if @host.scrollHeight - @host.scrollTop - @host.clientHeight > @opt.boundary => return
      if !@end and !@running => @fetch!then ~> @fire \scroll.fetch, it
    ), @opt.scroll-delay

  set-loader: ->
  parse-result: -> it
  fetch: (opt={}) -> new Promise (res, rej) ~> # TODO clear res when clearTimeout is called
    if @running or @end => return res []
    if @handle.fetch => clearTimeout @handle.fetch
    @handle.fetch = setTimeout (~>
      @running = true
      @_fetch!then (ret = []) ~>
        ret = @parse-result ret
        @running = false
        @offset += (ret.length or 0)
        if !ret.length =>
          @fire if !@offset => \empty else \finish
          @end = true
        res ret
    ), (opt.delay or @opt.fetch-delay or 200)

