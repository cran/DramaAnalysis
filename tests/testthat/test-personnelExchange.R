context("Personnel Exchange")

data(rksp.0)
toler = 1e-4


# hamming()

dist_trilcke  <- hamming(rksp.0)
test_that("hamming(rksp.0) has correct dimensions and produces correct output", {
  expect_true(inherits(dist_trilcke, "QDHamming"))
  expect_length(dist_trilcke, 42)
  expect_equal(dist_trilcke[1], 0.6666667, tolerance=toler)
})

dist_hamming  <- hamming(rksp.0, variant = "Hamming")
test_that("hamming(rksp.0, variant = 'Hamming') has correct dimensions and produces correct output", {
  expect_true(inherits(dist_hamming, "QDHamming"))
  expect_length(dist_hamming, 42)
  expect_equal(dist_hamming[1], 2)
})

dist_nhamming <- hamming(rksp.0, variant = "NormalizedHamming")
test_that("hamming(rksp.0, variant = 'NormalizedHamming') has correct dimensions and produces correct output", {
  expect_true(inherits(dist_nhamming, "QDHamming"))
  expect_length(dist_nhamming, 42)
  expect_equal(dist_nhamming[1], 0.1538462, tolerance=toler)
})


# scenciDifference()

dist <- scenicDifference(rksp.0)
test_that("scenicDifference(rksp.0) has correct dimensions and produces correct output", {
  expect_true(inherits(dist, "QDHamming"))
  expect_length(dist, 42)
  expect_equal(dist[1], 0.9230769, tolerance=toler)
  expect_equal(max(dist), 1)
})

dist <- scenicDifference(rksp.0, norm = 1)
test_that("scenicDifference(rksp.0, norm = 1) has correct dimensions and produces correct output", {
  expect_true(inherits(dist, "QDHamming"))
  expect_length(dist, 42)
  expect_equal(dist[1], 12)
  expect_equal(max(dist), 13)
})