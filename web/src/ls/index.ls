lc = {list: []}

view = new ldView do
  root: document.body
  text: count: -> lc.list.length
  handler: do
    item: do
      key: -> it.id
      list: -> lc.list or []
      init: ({node}) ->
      handler: ({node, data}) ->
        document.body.scrollTop
        node.classList.add \active
        ld$.find(node, '[ld=id]', 0).innerText = data.id

  action: click: do
    fetch: -> page.fetch!
    reset: ->
      view.get('reset').classList.toggle \d-none, true
      view.get('fetch').classList.toggle \d-none, false
      page.reset!
      lc.list = []
      view.render!

ldld = new ldLoader className: 'ldld full'
ldcv = new ldCover root: '.ldcv'

page = new ldPage do
  fetch: ->
    ldld.on!
    debounce 1000
      .then ~>
        ldld.off!
        len = if lc.list.length > 2 * @limit => 0 
        else if lc.list.length > 1.47 * @limit => Math.round(@limit * 0.47)
        else @limit
        return ( [0 til len].map -> {id: Math.random!toString(36)substring(2)} )

page.on \empty, -> console.log \empty
page.on \finish, ->
  view.get('reset').classList.toggle \d-none, false
  view.get('fetch').classList.toggle \d-none, true
  ldcv.toggle true

page.on \fetch, ->
  lc.[]list = it ++ lc.[]list
  view.render!
