require 'rearmed/methods'
require 'rearmed/exceptions'

module Rearmed

  @enabled_patches = eval(File.read(File.join(File.dirname(__FILE__), 'rearmed/default_enabled_patches.hash')))

  def self.enabled_patches=(val)
    @enabled_patches = val
  end

  def self.enabled_patches
    @enabled_patches
  end

end
