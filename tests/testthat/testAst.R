library(rjson);

context("AST tests");

test_that("Basics",{
 expect_identical(
  toJSON(r()$db("a")$table("b")$add()$query),
  "[24,[[15,[[14,[\"a\"]],\"b\"]]]]");
 expect_identical(
  toJSON(r()$db("a")$table("b")$query),
  "[15,[[14,[\"a\"]],\"b\"]]");

});

test_that("Functions",{
 Q<-r()$db("a")$table("b")$filter("XXX",function(x,y) r()$add(x,y))$query;
 expect_identical(toJSON(Q),
  "[39,[[15,[[14,[\"a\"]],\"b\"]],\"XXX\",[69,[[2,[1,2]],[24,[[10,1],[10,2]]]]]]]")
 expect_error(r()$filter(function() r()$add(1))$query);
 expect_error(r()$filter(list(a=function(x) x))$query,
  "Functions can only exist as direct term arguments.");
})

test_that("Make array appears",{
 Q<-r()$db(c("a","b","c"))$query;
 expect_identical(toJSON(Q),"[14,[[2,[\"a\",\"b\",\"c\"]]]]");
})
