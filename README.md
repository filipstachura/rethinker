# rethinker [![CRAN downloads](http://cranlogs.r-pkg.org/badges/rethinker)](https://cran.r-project.org/web/packages/rethinker/index.html)

Rethinker is a [RethinkDB](http://rethinkdb.com/) driver for [R](https://www.r-project.org/).
It is currently pretty usable, but mileage may vary; the main thing missing is the support for encryption connections, auth keys and v1.0 wire protocol.
All those things boil down to the fact that R has no support for cryptographic primitives nor for wrapping connections into TLS.

How to use
---------

The easiest way is to install from [CRAN](https://cran.r-project.org/web/packages/rethinker/index.html), i.e.,

```r
install.packages('rethinker')
```

To build from source, use the standard R build or devtools; for tests, use `devtools::test()` (read to the end before doing that).

Basically, the client works like this:

```r
library(rethinker)
cn<-openConnection(host,port)

# Sync query, will just print result
r()$db("someDb")$table("someTable")$count()$run(cn)
# ... or just
r("someDb","someTable")$count()$run(cn)

# Sync query, but will return cursor...
r()$db("someDb")$table("someTable")$orderBy(list(index='awe'))$run(cn)->cr
# ...you can move with...
cursorNext(cr)
# ...or close
close(cr)

# Async query...
r()$db("someDb")$table("someTable")$changes()$runAsync(cn,
 function(x){
  print(x);
  return(FALSE); #TRUE for more
 }
)
# Because R has no event loop, this must be called for cb to be executed;
# it will block till all installed cbs will either exhaust their queries
# or kill themselves by returning FALSE.
drainConnection(cn)

# Terms are named as in JS driver, options as in Python (snake_case);
# objects are lists, mapped as in rjson package
r()$db("someDb")$table("someTable")$insert(
 list(
  id="777",
  stuff=list(who="cares")
 ),
 conflict="update",
 return_changes=TRUE
)$run(cn)

# Brackets are replaced by $bracket(), do by $funcall(function,atts)
# Implicit var ("row") is not available; R anonymous functions are quite short and easy, there is no
#  need for additional syntax sugar.
```

Note that tests will try to spin a throw-away RethinkDB instance in temp with port offset 9876.
In some unlikely cases it may interfere with your production DB (when it re-uses port offset 9876 and there is a race condition) or generate a false positive (when RethinkDB fails to start in 5s or some firewall is blocking local traffic, etc.).
When RethinkDB is absent or cannot be started, transaction tests will be skipped.
