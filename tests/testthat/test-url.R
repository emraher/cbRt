context('Create URL')

test_that('Should stop for missing parameters', {
  expect_error(cbrt_url(series = 'TP.DK.USD.A', startDate = '01-10-2017', endDate = '01-11-2017'))
})

test_that('Should stop for NULL in required parameters', {
  expect_error(cbrt_url(series = 'TP.DK.USD.A', startDate = '01-10-2017', endDate = '01-11-2017', token = NULL))
})

# TODO -------------------------------------------------------------------------
# Include more tests