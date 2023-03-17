library(shinytest2)




test_that("{shinytest2} recording: test_stat_assist_value", {
  app <- AppDriver$new(name = "test_stat_assist_value", seed = 532, height = 794, 
      width = 1211)
  app$set_inputs(stat_select = "Assists")
  app$expect_values()
})



test_that("{shinytest2} recording: test_stat_rebound_value", {
  app <- AppDriver$new(name = "test_stat_rebound_value", height = 794, width = 1211)
  app$set_inputs(stat_select = "Rebounds")
  app$expect_values()
})



test_that("{shinytest2} recording: test_stat_block_value", {
  app <- AppDriver$new(name = "test_stat_block_value", height = 866, width = 1211)
  app$set_inputs(stat_select = "Blocks")
  app$expect_values()
})
