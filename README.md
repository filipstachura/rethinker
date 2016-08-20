# rethinker [![CRAN downloads](http://cranlogs.r-pkg.org/badges/rethinker)](https://cran.r-project.org/web/packages/rethinker/index.html)

Rethinker is a [RethinkDB](http://rethinkdb.com/) driver for [R](https://www.r-project.org/).
It is currently pretty usable, but mileage may vary; the only thing missing from *full-featured* is an auth key support, although documentation and test coverage is still far from perfect.

How to use
---------

The easiest way is to install from [CRAN](https://cran.r-project.org/web/packages/rethinker/index.html), i.e.,

```r
install.packages('rethinker')
```

To install from source, use `devtools::install_github`.

Basically, it works like this:

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
)$run(cr)

# Brackets are replaced by $bracket(), do by $funcall(function,atts)
```
