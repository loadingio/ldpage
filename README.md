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


# License

MIT.
