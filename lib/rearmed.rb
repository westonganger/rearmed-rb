module Rearmed
  def self.recursive_require(path, file_name="**/*.rb")
    require_each(path, file_name)
  end

  class << self
    alias_method :recursive_require_folder, :recursive_require
  end

  def self.require_folder(path, file_name="*.rb")
    require_each(path, file_name)
  end

  def self.naturalize_str(str)
    str.to_s.split(/(\d+)/).map{|a| a =~ /\d+/ ? a.to_i : a}
  end

  def self.valid_float(str)
    str =~ /(^(\d+)(\.)?(\d+)?)|(^(\d+)?(\.)(\d+))/
  end

  class NaturalSortBlockFoundError < StandardError
    def initialize(klass=nil)
      super("Reaarmed doesn't yet support blocks on the natural_sort method")
    end
  end

  class NoArgOrBlockGivenError < StandardError
    def initialize(klass=nil)
      super("Must pass an argument or a block.")
    end
  end

  class BothArgAndBlockError < StandardError
    def initialize(klass=nil)
      super("Arguments and blocks must be used seperately.")
    end
  end

  private

  def self.require_each(path, file_name)
    file_name = File.join(File.dirname(__FILE__), path, file_name)
    Dir[file_name].each{|file| require file}
  end

  ENABLED = {
    string: {valid_float: true, not_nil: true, to_bool: true},
    boolean: {is_true: true, is_false: true},
    array: {natural_sort: true, index_all: true, find: true},
    rails_3: {hash: false, pluck: true, update_columns: true, all: true},
    enumerable: {natural_sort_by: true},
    object: {in: true}
  }
end
