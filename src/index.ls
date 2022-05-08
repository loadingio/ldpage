paginate = (opt = {}) ->
  if opt.fetch => @_user_fetch = opt.fetch; delete opt.fetch
  @ <<< {
    _evthdr: {}
    _hdl: {}
    data: {}
    offset: 0
    running: false
    end: false
    # we use `disabled to better semantic align with `running` and `end`
    disabled: (if opt.enabled? => !opt.enabled else false)
  }
  @_o = {
    # https://stackoverflow.com/questions/3898130/#comment92747215_34550171
    boundary: 5
    limit: 20
    offset: 0
    scroll-delay: 100
    fetch-delay: 200
    fetch-on-scroll: false
  } <<< opt
  @ <<< @_o{limit, offset}
  if @_o.host => @set-host @_o.host
  #@fetch = debounce @_o.fetch-delay, ~> @_fetch.apply @, arguments
  @fetch = debounce @_o.fetch-delay, @_fetch
  @

paginate.prototype = Object.create(Object.prototype) <<< do
  # should be overwritten
  _user_fetch: -> new Promise (res, rej) -> return res []
  toggle: (v) -> @disabled = if v? => !v else !@disabled
  on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @_evthdr.[][n].push cb
  fire: (n, ...v) -> for cb in (@_evthdr[n] or []) => cb.apply @, v
  reset: (opt = {}) ->
    for k,v of @_hdl => clearTimeout v
    @ <<< offset: 0, end: false
    if opt.data => @data = opt.data
  init: (opt) -> @reset opt
  fetchable: -> !(@disabled or @end or @running)
  is-end: -> @end
  set-host: (host) ->
    if !host => host = document.scrollingElement
    if @host and @_scroll-func => @host.removeEventListener \scroll, @_scroll-func
    @_scroll-func = (e) ~> @on-scroll e
    @host = (if typeof(host) == \string => document.querySelector(host) else host)
    if !@host => @host = null; return
    if @_o.fetch-on-scroll and !@_o.pivot => @host.addEventListener \scroll, @_scroll-func

    update = (ns) ~>
      if !( ns.map(->it.isIntersecting).filter(->it).length and @fetchable! ) => return
      @fetch!then ~> @fire \scroll.fetch, it

    if @obs and @_o.pivot => @obs.unobserve @_o.pivot
    if @_o.pivot =>
      @obs = new IntersectionObserver update, {}
      @obs.observe @_o.pivot

  on-scroll: ->
    if !@fetchable! => return
    clearTimeout @_hdl.scroll
    # window doesn't have scrollHeight, scrollTop and clientHeight thus we fallback to scrollingElement
    h = if @host == window => document.scrollingElement else @host
    @_hdl.scroll = setTimeout (~>
      if h.scrollHeight - h.scrollTop - h.clientHeight > @_o.boundary => return
      if @fetchable! => @fetch!then ~> @fire \scroll.fetch, it
    ), @_o.scroll-delay

  _fetch: (opt={}) ->
    if !@fetchable! => return res []
    @fire \fetching
    @running = true
    @_user_fetch!then (r = []) ~>
      @running = false
      @offset += (r.length or 0)
      @fire \fetch, r
      if r.length < @limit =>
        @end = true
        @fire (if !@offset => \empty else \finish)
      return r

  _fetchx: (opt={}) -> new Promise (res, rej) ~> # TODO clear res when clearTimeout is called
    if !@fetchable! => return res []
    if @_hdl.fetch => clearTimeout @_hdl.fetch
    @fire \fetching
    @_hdl.fetch = setTimeout (~>
      @running = true
      @_user_fetch!then (ret = []) ~>
        @running = false
        @offset += (ret.length or 0)
        @fire \fetch, ret
        if ret.length < @limit =>
          @end = true
          @fire (if !@offset => \empty else \finish)
        res ret
    ), (opt.delay or @_o.fetch-delay or 200)

if module? => module.exports = paginate
else if window? => window.paginate = paginate
