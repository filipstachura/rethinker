context("Transactions");

skipCon<-TRUE;
try(openConnection(),silent=TRUE)->J;
if(!inherits(J,"try-error")){
 #Init DB for testing
 skipCon<-FALSE;
 r()$db("test")$tableList()$run(J)->tables;
 if("rethinker_tests"%in%tables)
  r()$db("test")$tableDrop("rethinker_tests")$run(J);
 close(J);
}

test_that("Connection prints",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 expect_output(print(J),"Opened");
 close(J);
});

test_that("Make table",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 r()$db("test")$tableCreate("rethinker_tests")$run(J)->ans;
 expect_equal(ans$tables_created,1);
 close(J);
});

test_that("Insert, read and delete an object",{
 if(skipCon) skip("No connection to RethinkDB.");
 obj<-list(
  id=0,
  a=list(b=1,c=list(ca=LETTERS,cb=letters),d=3:5),
  d=6,e="siedem",
  f=8:10);
 J<-openConnection();
 expect_equal(
  r()$db("test")$table("rethinker_tests")$insert(obj)$run(J)$inserted,
  1);
 expect_equal(
  r()$db("test")$table("rethinker_tests")$get(0)$run(J)$a$c$ca,
  LETTERS);
 expect_equal(
  r()$db("test")$table("rethinker_tests")$get(0)$delete()$run(J)$deleted,
  1);
 close(J);
});

test_that("Bulk insert, cursor",{
 if(skipCon) skip("No connection to RethinkDB.");
 lapply(1:1000,function(x) list(id=x,tester=77))->tins;
 J<-openConnection();
 expect_equal(
  r()$db("test")$table("rethinker_tests")$insert(tins)$run(J)$inserted,
  1000);
 cur<-r()$db("test")$table("rethinker_tests")$run(J);

 expect_equal(
  cursorNext(cur)$tester,
  77);
 cursorNext(cur,inBatch=TRUE)->stuff;
 expect_gt(length(stuff),10);
 expect_equal(stuff[[6]]$tester,77);
 expect_equal(
  r()$db("test")$table("rethinker_tests")$delete()$run(J)$deleted,
  1000);
 close(J);
});

test_that("Cursor emptying",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 r()$db("test")$table("rethinker_tests")$changes()$run(J)->cur;
 expect_output(print(cur),"Active");
 close(cur); Sys.sleep(1);
 expect_output(print(cur),"Empty");
 expect_identical(cursorNext(cur),NULL);
 expect_identical(cursorNext(cur,inBatch=TRUE),list());

 r()$db("test")$table("rethinker_tests")$changes()$run(J)->cur;
 close(J); Sys.sleep(1);
 expect_output(print(cur),"Empty");
 expect_identical(cursorNext(cur),NULL);
 expect_identical(cursorNext(cur,inBatch=TRUE),list());
 close(cur);
});

test_that("Async queries",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 had<-FALSE;
 r()$db("test")$table("rethinker_tests")$changes()$runAsync(J,function(r){
  had<<-TRUE;
  return(FALSE);
 });
 Sys.sleep(1); #Wait for changes observer to settle down
 r()$db("test")$table("rethinker_tests")$insert(list(id='zz',n=runif(10)),conflict="update")$run(J);
 drainConnection(J);
 expect_identical(had,TRUE);
 r()$db("test")$table("rethinker_tests")$delete()$run(J);
 close(J);
})

test_that("Sync-async mix",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 r()$db("test")$table("rethinker_tests")$delete()$run(J);
 asyncCount<-0;
 r()$db("test")$table("rethinker_tests")$changes()$runAsync(J,function(r){
  asyncCount<<-asyncCount+1;
  return(asyncCount<5);
 });
 asyncCount2<-0;
 r()$db("test")$table("rethinker_tests")$changes()$runAsync(J,function(r){
  asyncCount2<<-asyncCount+1;
  return(asyncCount2<5);
 });
 r()$db("test")$table("rethinker_tests")$changes()$run(J)->cursor;
 Sys.sleep(1); #Wait for changes observer to settle down

 for(e in 1:5)
  r()$db("test")$table("rethinker_tests")$insert(list(id=220+e,n=runif(10)))$run(J);

 drainConnection(J);
 expect_equal(asyncCount,5);
 expect_equal(asyncCount2,5);
 cursorNext(cursor,inBatch=TRUE)->stuff;
 expect_equal(length(stuff),5);

 r()$db("test")$table("rethinker_tests")$delete()$run(J);
 close(J);
});

test_that("Profile",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 expect_message(
  r()$db("test")$table("rethinker_tests")$count()$run(J,profile=TRUE),
  "Saved profile");
 expect_true(!is.null(J$lastProfile[[1]]$description));
 close(J);
});

test_that("Simple expression",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 expect_equal(r()$add(r()$add(1,2),4)$run(J),7);
 close(J);
});

test_that("Map-reduce",{
 if(skipCon) skip("No connection to RethinkDB.");
 lapply(1:100,function(x) list(id=x,val=list(vall=x)))->tins;
 J<-openConnection();
 expect_equal(
  r()$db("test")$table("rethinker_tests")$insert(tins)$run(J)$inserted,
  100);

 r()$db("test")$table("rethinker_tests")$map(
  function(x) x$bracket("val")$bracket("vall")
 )$reduce(
  function(l,r) r()$add(l,r)
 )$run(J)->ans;

 expect_equal(
  r()$db("test")$table("rethinker_tests")$delete()$run(J)$deleted,
  100);
 close(J);
});

test_that("r() parameters",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 expect_equal(
  r("test","rethinker_tests")$insert(list(id="xyz"))$run(J)$inserted,
  1);
 expect_equal(
  r("test","rethinker_tests")$delete()$run(J)$deleted,
  1);
 close(J);
});

test_that("Expr",{
 if(skipCon) skip("No connection to RethinkDB.");
 J<-openConnection();
 expect_equal(r()$expr(list(a=1,b=2,c=3))$keys()$run(J),c('a','b','c'));
 close(J);
});
