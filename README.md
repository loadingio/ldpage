# ldpage

Fetching data with paging functionality supported:

 - keep pagination state ( `limit` & `offset` )
 - auto fetching on scrolling or event
 - stop fetching on end of data ( returned length < limit )


# Usage

install vis npm:

    npm install ldpage

and include required js lib:

    <script src="path-to/index.min.js"></script>


create a ldpage object:

    mypal = new ldpage({
      fetch: -> ld$.fetch '...' , {}, {type: \json}
    })


you can process fetched data directly in the fetch function:

    mypal = new ldpage do
      fetch: ->
        ld$.fetch '...' , {}, {type: \json}
          .then ->
            render(it)
            return it


see `src/sample.ls`.


## Constructor Options

 - `limit`: default 20. maximal count return per fetch
 - `offset`: default 0. offset for fetch to start
 - `scrollDelay`: default 100. debounce time (ms) before fetching after scrolled.
 - `fetchDelay`: default 200. debounce time (ms) before fetching when fetch is called.
 - `fetchOnScroll`: default false. when true, fetch when scrolling to the bottom of `host`.
 - `boundary`: defaul 0. threshold of the distance to `host` bottom to trigger fetch.
   - omitted if `fetchOnScroll` is false.
   - larger `boundary` makes fetch triggered earlier.
 - `host`: container that scrolls. default `document.scrollingElement`.
 - `fetch`: required custom function to fetch data according to ldpage's status.
   - when called, - use `this.limit` and `this.offset` for current position of fetch progress.
   - should return an Array. ldpage use it to update `this.offset` and count progress.
 - `enabled`: default true. when false, fetch won't start until re-enabled by `toggle(v)`.


## Method

 - `reset(opt)`: reset page. opt:
   - `data`: data for use in this bunch of fetch.
 - `init(opt)`: reset page. deprecated. ( use reset instead )
 - `fetch`: fetch data again.
 - `isEnd`: is there anything to fetch.
 - `setHost(node)`: set scrolling host. for entire document, use `window`.
 - `toggle(v)`: flip enabled/disabled statue. force set to v if v(true or false) is provided.


## Events

 - `empty`: fired when ldpage confirms that the list is empty.
 - `finish`: fired when ldpage confirms that all items are fetched.
 - `fetch`: fired when ldpage fetch a new list of data
 - `scroll.fetch`: fired when ldpage fetch a new list of data triggered by scrolling. can happen along with `fetch` event.
 - `fetching`: fired before fetch is called.


# License

MIT
