lc = {list: [], list-alt: []}

ldld = new ldloader className: 'ldld full'
ldcv = new ldcover root: '.ldcv'

prepare = (o = {}) ->
  {root, opt} = o
  lc = {list: []}
  view = new ldview do
    init-render: false
    root: root
    text: count: -> lc.list.length
    handler:
      finish: ({node}) -> node.classList.toggle \d-none, !lc.page.is-end!
      reset: ({node}) -> node.classList.toggle \d-none, !lc.page.is-end!
      fetch: ({node}) -> node.classList.toggle \d-none, lc.page.is-end!
      item: do
        key: -> it.id
        list: -> lc.list or []
        init: ({node}) ->
        handler: ({node, data}) ->
          node.classList.add \active
          ld$.find(node, '[ld=id]', 0).innerText = data.id
    action: click: do
      fetch: -> page.fetch!
      reset: ->
        lc.list = []
        lc.page.reset!then -> view.render!

  lc.page = page = new paginate {
    fetch: ->
      ldld.on!
      debounce 1000
        .then ~>
          ldld.off!
          len = if lc.list.length > 2 * @limit => 0
          else if lc.list.length > 1.47 * @limit => Math.round(@limit * 0.47)
          else @limit
          return [0 til len].map ~> {id: 1 + it + @offset}
  } <<< opt

  page.on \empty, -> console.log \empty
  page.on \finish, ->
    view.render <[reset fetch finish]>
    #ldcv.toggle true
  page.on \fetch, ->
    lc.[]list = lc.[]list ++ it
    view.render!
  view.render!

prepare({
  root: ld$.find("[ld-scope='fetch1']", 0)
  opt:
    fetch-on-scroll: true
    host: document.scrollingElement
})

prepare({
  root: ld$.find("[ld-scope='fetch2']", 0)
  opt:
    fetch-on-scroll: true
    pivot: ld$.find("[ld-scope='fetch2'] [ld='pivot']",0)
})

prepare({
  root: ld$.find("[ld-scope='fetch3']", 0)
  opt:
    fetch-on-scroll: false
    host: ld$.find("[ld-scope='fetch3'] [ld='host']",0)
    fetch-on-init: \lazy
})
