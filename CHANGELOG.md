CHANGELOG
---------

- **Unreleased** - [View Diff](https://github.com/westonganger/rearmed-rb/compare/v2.0.2...master)
  - Add `Hash#deep_set`

- **2.0.2 - July 15, 2018** - [View Diff](https://github.com/westonganger/rearmed-rb/compare/v2.0.1...v2.0.2)
  - Fix bug where `String#valid_integer?` would return true on empty strings
  - Change `String#to_bool` to use a case-insensitive match to allow uppercase values such as `TRUE` and `FALSE`
  - Fix bug where multi-line strings could return a false positive status if one line matched. This bug affected the following methods: `String#valid_integer?`, `String#valid_float?`, `String#to_bool`. The problem was related to using the wrong anchor which matched the beginning/end of the line instead of the beginning/end of entire string. 

- **2.0.1 - July 12, 2018** - [View Diff](https://github.com/westonganger/rearmed-rb/compare/v2.0.0...v2.0.1)
  - Fix Ruby 1.9.3 support. Do not use `__dir__` because Ruby 1.9.3 does not support it.
  - Fix tests. Add `wwtd` for better local testing.

- **2.0.0 - July 11, 2018** - [View Diff](https://github.com/westonganger/rearmed-rb/compare/v1.3.1...v2.0.0)
  - Rename all generic `Rearmed` methods to their respective object type subclass and add type checking. Three examples:
    - `Rearmed.casecmp?(str1, str2)` changed to `Rearmed::String.casecmp?(str1, str2)`
    - `Rearmed.hash_join(h)` changed to `Rearmed::Hash.join?(h)`
    - `Rearmed.dig` is the only exception will remained at the global `Rearmed` namespace. This method is shared by both Array and Hash and also is used internally throughout the library.
  - Change method of applying patches from `require 'rearmed/apply_patches'` to `Rearmed#apply_patches!`. Once `apply_patches!` has been called, then `enabled_patches` cannot be changed. If it is, it will raise a `PatchesAlreadyAppliedError`
  - Overhaul `Rearmed#enabled_patches=` method with type checking
  - Allow setting `:all` for `Rearmed#enabled_patches=`
  - Add `Integer#length`, `Object#bool?`, `Object#true?`, `Object#false?`, `String#match?`. These methods were all borrowed from [`finishing_moves`](https://github.com/forgecrafted/finishing_moves), Thanks!

- **1.3.1 - Sept 2, 2017**
  - Add `Enumerable#select_map`
  - Add `String#casecmp?` for Ruby 2.3.x and below
  - Fix ruby 1.9.3 lambda syntax cannot contain space between stab and parenthesis

- **1.3.0 - Feb 28, 2017**
  - Remove Rails and Minitest methods. Those methods moved to https://github.com/westonganger/rearmed_rails
  - Change methods names of Rearmed namespaced hash methods to convey better meaning

- **1.2.2 - Feb 19, 2017**
  - Add `field_is_array`, `options_for_select_include_blank`, `options_from_collect_for_select_include_blank`
  - Namespace rails patches to active_record and other

- **1.2.1 - Jan 24, 2017**
  - Add Hash `join`, `to_struct`
  - Fix `find_duplicates`
  - Some minor refractoring

- **1.2.0 - September 3, 2016**
  - Add Minitest patches `assert_changed` & `assert_not_changed`
  - Remove `dedupe` in favor of new `find_duplicates`
  - Add ActiveRecord `newest`

- **1.1.1 - August 20, 2016**
  - Add Array `not_empty?`

- **1.1.0 - July 8, 2016**
  - Add ActiveRecord `find_or_create`, `reset_table`, `reset_auto_increment`, `depupe`
  - Add `starts_with?`, `begins_with?`, `ends_with?` aliases
  - Major improvements to opt-in system
  - Allow Hash compact work without ActiveSupport
  - Only allow `in?` patch without ActiveSupport
  - Move some methods to Rearmed for use outside of monkey patching
  - Add test's for everything except for the Rails methods (Would love a PR for the Rails tests)

- **1.0.3 - June 20, 2016**
  - Useless version update
  - I Thought the `delete_first` method still wasn't fixed but my app was incorrect instead

- **1.0.2 - June 20, 2016**
  - Fix array `delete_first` method

- **1.0.1 - June 17, 2016**
  - Add `pluck_to_hash`
  - Add `pluck_to_struct`
  - Reorganize rails patches to have generic rails patches

- **1.0.0 - June 8, 2016**
  - Ready for public use
  - Major improvements to opt-in system
  - Move some methods to Rearmed for use outside of monkey patching

- **0.9.1 - June 02, 2016**
  - Add many new methods
  - Switch to opt-in monkey patching

- **0.9.0 - April 30, 2016**
  - Gem Initial Release
