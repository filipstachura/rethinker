library(rethinker)
cn<-openConnection()

# Example simple queries setting up a throw-away db and table
r()$dbCreate("rethinker_test")$run(cn)
# ... note that those are sync queries, so there is NO race condition
# of making table in a yet-not-created db
r()$db("rethinker_test")$tableCreate("A")$run(cn)

# Something that returns results
r()$db("rethinker_test")$table("A")$count()$run(cn)->ans
# ...empty tables have no items:
stopifnot(identical(ans,0))
# $db()$table() is long to type, fortunately there is a shortcut
r("rethinker_test","A")$count()$run(cn)->ans2

# Let's insert an object; we follow rjson R-objects<->JSON mapping
r("rethinker_test","A")$insert(
 list(
  id='a',
  string='abc',
  number=7,
  array=1:10,
  #JSON arrays may have different types
  another_array=list(1,'two',3),
  object=list(three=3,array=letters[1:3],sub=list(i_am="a nested object"))
 )
)$run(cn)->ans3
# should have made a new object
stopifnot(identical(ans3$inserted,1))

# Let's now retrieve it
r("rethinker_test","A")$get("a")$run(cn)->ans4
# ... note that objects keys have been sorted; UNLIKE R, JSON does not store
# object's element order, neither does RethinkDB
str(ans4)

# You can also store more elements at once...
r("rethinker_test","A")$insert(
 list(
  list(id="b",number=17),
  list(id="c",number=-3)
 )
)$run(cn)
# ... or use JSON (which may be faster for complex objects)
r("rethinker_test","A")$insert(
 r()$json('{"id":"d","number":49}')
)$run(cn)
# Note that we had to use r() again to retrieve the ReQL root

# We can update as well
r("rethinker_test","A")$update(
 list(
  id="c",
  number=21
 )
)$run(cn)->ans
stopifnot(identical(ans$replaced,1))

# x$bracket('number')$gt(20)
# Filter; note that one HAS TO use ReQL operations only
r("rethinker_test","A")$filter(
 function(x) r()$and(x$bracket('number')$lt(30),TRUE)
)$run(cn)->ansX

r("rethinker_test","A")$filter(
 function(x) x$bracket('number')$lt(30)$and(TRUE)
)$run(cn)->ansX
