paginate = (o = {}) ->
  if o.fetch => @_user_fetch = o.fetch
  @ <<< {
    _evthdr: {}
    _running: false
    _end: false
    # we use `disabled to better semantic align with `running` and `end`
    _disabled: (if o.enabled? => !o.enabled else false)
  }
  @_o = {
    # https://stackoverflow.com/questions/3898130/#comment92747215_34550171
    boundary: 5
    scroll-delay: 100
    fetch-delay: 200
    fetch-on-scroll: false
    fetch-on-init: false
  } <<< o
  @ <<< limit: o.limit or 20, offset: o.offset or 0
  if o.host => @host o.host
  if o.pivot => @pivot o.pivot
  @fetch = debounce @_o.fetch-delay, @_fetch
  @_pend = proxise ~> if !@_running => Promise.resolve!
  if @_o.fetch-on-init in <[always once]> => @fetch!
  @

paginate.prototype = Object.create(Object.prototype) <<< do
  _user_fetch: -> new Promise (res, rej) -> return res []
  toggle: (v) -> @_disabled = if v? => !v else !@_disabled
  on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @_evthdr.[][n].push cb
  fire: (n, ...v) -> for cb in (@_evthdr[n] or []) => cb.apply @, v
  reset: (o = {}) ->
    @_pend!then ~>
      @ <<< offset: 0, _end: false
      if @_o.fetch-on-init == \always => @fetch!
  fetchable: -> !(@_disabled or @_end or @_running)
  is-end: -> @_end

  obs: ->
    if @_obs => return @_obs
    update = (ns) ~>
      if !( ns.map(->it.isIntersecting).filter(->it).length and @fetchable! ) => return
      p = ns.filter(~> it.target == @_pivot).length
      h = ns.filter(~> it.target == @_host).length
      if (
        (@_o.fetch-on-scroll and p) or
        (@_o.fetch-on-init == \lazy and h and !@offset)
      ) => @fetch!then ~> @fire \scroll.fetch, it
    @_obs = new IntersectionObserver update, {}
    return @_obs

  _on-scroll: ->
    if !@fetchable! => return
    h = @_host
    if h.scrollHeight - h.scrollTop - h.clientHeight > @_o.boundary => return
    @fetch!then ~> @fire \scroll.fetch, it

  host: (h) ->
    if !h => return @_host
    obs = @obs!
    if @_host and @_scroll-func =>
      n = if @_host == document.scrollingElement => document else @_host
      n.removeEventListener \scroll, @_scroll-func
      @_scroll-func = null
    if @_host => obs.unobserve @_host
    @_host = (if typeof(h) == \string => document.querySelector(h) else h)
    if !@_host => return
    if @_o.fetch-on-scroll and !@_pivot =>
      @_scroll-func = (e) ~> @_on-scroll e
      n = if @_host == document.scrollingElement => document else @_host
      n.addEventListener \scroll, @_scroll-func
    obs.observe @_host

  pivot: (p) ->
    if !p => return @_pivot
    obs = @obs!
    if @_pivot => obs.unobserve @_pivot
    @_pivot = (if typeof(p) == \string => document.querySelector(p) else p)
    obs.observe (@_pivot = p)
    if @_host and @_scroll-func =>
      n = if @_host == document.scrollingElement => document else @_host
      n.removeEventListener \scroll, @_scroll-func
      @_scroll-func = null

  _fetch: (opt={}) ->
    if !@fetchable! => return res []
    @fire \fetching
    @_running = true
    @_user_fetch!then (r = []) ~>
      @_running = false
      @offset += (r.length or 0)
      @fire \fetch, r
      if r.length < @limit =>
        @_end = true
        @fire (if !@offset => \empty else \finish)
      @_pend.resolve!
      return r

if module? => module.exports = paginate
else if window? => window.paginate = paginate
