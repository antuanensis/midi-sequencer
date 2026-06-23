# Regression Plan

Before merging meaningful engine changes:

- Run `swift test`.
- Add a focused regression test for the behavior being changed.
- Check that probability tests use explicit seeds.
- Check that Codable changes include round-trip tests once persistence exists.
