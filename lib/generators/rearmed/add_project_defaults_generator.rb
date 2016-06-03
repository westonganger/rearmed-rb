require 'rails/generators'

module Rearmed
  class Setup < Rails::Generators::Base

    def setup
      contents = <<eos
Rearmed.module_eval do
  const_set('ENABLED', {
      to_bool: false,
      valid_integer: false,
      valid_float: false
    },
    rails_3: {
      hash_compact: false,
      pluck: false,
      update_columns: false,
      all: false,
    },
    rails_4: {
      find_relation_each: false,
      find_in_relation_batches: false,
      or: false,
      link_to_confirm: false,
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
    }
  }
end

Rearmed.require_folder 'rearmed'
eos

      create_file "config/initializers/rearmed.rb", contents
    end

  end
end
