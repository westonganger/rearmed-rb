require 'rails/generators'

module Rearmed
  class SetupGenerator < Rails::Generators::Base

    def setup
      create_file "config/initializers/rearmed.rb", <<eos
Rearmed.enabled_patches = #{File.read(File.join(File.dirname(__FILE__), '../../rearmed/default_enabled_patches.hash'))}

require 'rearmed/apply_patches'
eos
    end

  end
end
