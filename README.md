# ldPage

Pagination library.


# Usage

```
    mypal = new ldPage do
      fetch: -> 
        ld$.fetch '...' , {}, {type: \json}
          .then -> return it
```

see src/sample.ls.


## Configuration

 * host - scrolling host. for entire document, use `window`.
 * fetch-on-scroll - should ldPage fetch data when scrolling to the bottom of the host. default false.
 * fetch - custom function to fetch data according to ldPage's status.
   - use this.limit and this.offset to control the current position of fetch progress.
   - should return the list fetched for ldPage to count progress.
 * fetch-delay - delay before fetching when fetch is called.


## Mesthod

 * setHost(node) - set scrolling host. for entire document, use `window`.


# License

MIT.
