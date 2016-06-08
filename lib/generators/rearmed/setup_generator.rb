require 'rails/generators'

module Rearmed
  class SetupGenerator < Rails::Generators::Base

    def setup
      contents = <<eos
Rearmed.enabled_patches = {
  rails_4: {
    find_relation_each: false,
    find_in_relation_batches: false,
    or: false,
    link_to_confirm: false
  },
  rails_3: {
    hash_compact: false,
    pluck: false,
    update_columns: false,
    all: false
  },
  string: {
    to_bool: false,
    valid_integer: false,
    valid_float: false
  },
  hash: {
    only: false,
    dig: false
  },
  array: {
    index_all: false,
    find: false,
    dig: false,
    delete_first: false
  },
  enumerable: {
    natural_sort: false,
    natural_sort_by: false
  },
  object: {
    in: false,
    not_nil: false
  },
  date: {
    now: false
  }
}

require 'rearmed/apply_patches'
eos

      create_file "config/initializers/rearmed.rb", contents
    end

  end
end
