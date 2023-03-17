library(shinytest2)



test_that("{shinytest2} recording: test_stat_assist_rebound", {
  app <- AppDriver$new(variant = platform_variant(), name = "test_stat_assist_rebound", 
      height = 749, width = 1139)
  app$set_inputs(stat_select = "Assists")
  app$set_inputs(stat_select = "Rebounds")
  app$expect_values()
  app$expect_screenshot()
})

test_that("{shinytest2} recording: test_whole_career", {
  app <- AppDriver$new(variant = platform_variant(), name = "test_whole_career", 
      height = 749, width = 1139)
  app$set_inputs(wholecareer_tick = TRUE)
  app$expect_screenshot()
})





