# rethinker

Rethinker is a [RethinkDB](http://rethinkdb.com/) driver for [R](https://www.r-project.org/).
It is currently *work-in-progress*; pretty usable, but mileage may vary.

How to use
---------

It is a devel version, and it is still not on CRAN; to this end you must compile the package yourself.
Fire `updpak.sh` and then execute `R CMD INSTALL rethinker_x.y.z.tar.gz`.
This will build `roxygen2` documentation and fire `testthat2` tests (both of those packages, as well as `devtools`, should be installed; note that `devtools::install_github` will not work).

Auto-executed tests expect a RethinkDB install active under localhost, in which they will make mess; to disallow, remove `tests/testthat/testTransactions.R`.

Basically, it works like this:

```r
library(rethinker)
cn<-openConnection(host,port)

# Sync query, will just print result
r()$db("someDb")$table("someTable")$count()$run(cn)

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
