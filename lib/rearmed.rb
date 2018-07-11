require 'rearmed/version'

require 'rearmed/methods'
require 'rearmed/exceptions'

module Rearmed

  DEFAULT_PATCHES = {
    array: {}, 
    date: {}, 
    enumerable: {}, 
    hash: {}, 
    integer: {}, 
    object: {}, 
    string: {}, 
  }.freeze
  private_constant :DEFAULT_PATCHES
  
  @enabled_patches = Marshal.load(Marshal.dump(DEFAULT_PATCHES)) 
  @applied = false

  def self.enabled_patches=(val)
    if @applied
      raise ::Rearmed::Exceptions::PatchesAlreadyAppliedError.new
    else
      if val.nil?
        @enabled_patches = Marshal.load(Marshal.dump(DEFAULT_PATCHES)) 
      elsif val == :all
        @enabled_patches = val
      elsif val.is_a?(Hash)
        keys = DEFAULT_PATCHES.keys

        keys.each do |k|
          methods = val[k] || val[k.to_sym]
          if methods
            if methods.is_a?(Hash) || methods == true
              @enabled_patches[k] = methods
            else
              raise TypeError.new('Invalid value within the hash passed to Rearmed.enabled_patches=')
            end
          else
            @enabled_patches[k] = {}
          end
        end
      else
        raise TypeError.new('Invalid value passed to Rearmed.enabled_patches=')
      end
    end
  end

  def self.enabled_patches
    @enabled_patches
  end

  def self.apply_patches!
    if @applied 
      raise ::Rearmed::Exceptions::PatchesAlreadyAppliedError.new
    else
      Dir[File.join(__dir__, 'rearmed/monkey_patches/*.rb')].each do |filename| 
        require filename
      end

      @applied = true 
    end
  end

end
