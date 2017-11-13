# rethinker [![CRAN downloads](http://cranlogs.r-pkg.org/badges/rethinker)](https://cran.r-project.org/web/packages/rethinker/index.html) [![Build Status](https://travis-ci.org/mbq/rethinker.svg?branch=master)](https://travis-ci.org/mbq/rethinker) [![Build Status](https://travis-ci.org/mbq/rethinker.svg?branch=devel)](https://travis-ci.org/mbq/rethinker)

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

See [wiki](https://github.com/mbq/rethinker/wiki) for tutorial.

Note that tests will try to spin a throw-away RethinkDB instance in temp with port offset 9876.
In some unlikely cases it may interfere with your production DB (when it re-uses port offset 9876 and there is a race condition) or generate a false positive (when RethinkDB fails to start in 5s or some firewall is blocking local traffic, etc.).
When RethinkDB is absent or cannot be started, transaction tests will be skipped.
