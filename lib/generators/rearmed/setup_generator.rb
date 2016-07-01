require 'rails/generators'

module Rearmed
  class SetupGenerator < Rails::Generators::Base

    def setup
      create_file "config/initializers/rearmed.rb", <<eos
Rearmed.enabled_patches = {
  rails_4: {
    or: false,
    link_to_confirm: false
  },
  rails_3: {
    hash_compact: false,
    pluck: false,
    update_columns: false,
    all: false
  },
  rails: {
    pluck_to_hash: false,
    pluck_to_struct: false,
    find_or_create: false,
    reset_table: false,
    reset_auto_increment: false,
    dedupe: false,
    find_relation_each: false,
    find_in_relation_batches: false,
  },
  string: {
    valid_integer: false,
    valid_float: false,
    to_bool: false,
    starts_with: false,
    begins_with: false,
    ends_with: false,
  },
  hash: {
    only: false,
    dig: false
  },
  array: {
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
    end

  end
end
