require 'rails/generators'

module Rearmed
  class Setup < Rails::Generators::Base

    def setup
      contents = ""\
      "Rearmed.module_eval do\n"\
      "  const_set('ENABLED', {\n"\
      "      to_bool: false,\n"\
      "      valid_integer: false,\n"\
      "      valid_float: false\n"\
      "    },\n"\
      "    rails_3: {\n"\
      "      hash_compact: false,\n"\
      "      pluck: false,\n"\
      "      update_columns: false,\n"\
      "      all: false,\n"\
      "    },\n"\
      "    hash: {\n"\
      "      only: false,\n"\
      "      dig: false\n"\
      "    },\n"\
      "    array: {\n"\
      "      index_all: false,\n"\
      "      find: false,\n"\
      "      dig: false,\n"\
      "      delete_first: false\n"\
      "    },\n"\
      "    enumerable: {\n"\
      "      natural_sort: false,\n"\
      "      natural_sort_by: false\n"\
      "    },\n"\
      "    object: {\n"\
      "      in: false,\n"\
      "      not_nil: false\n"\
      "    },\n"\
      "  }\n"\
      "end\n\n"\
      "Rearmed.require_folder 'rearmed'"

      create_file "config/initializers/rearmed.rb", contents
    end

  end
end
