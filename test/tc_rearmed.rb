#!/usr/bin/env ruby -w
require 'yaml'
require 'minitest'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rearmed.rb'

require 'minitest/autorun'

class TestRearmed < MiniTest::Test
  def setup
    @array = ["1.1","1.11","1.2","1.22"]
    @hash_array = [{version: "1.1"}, {version: "1.11"}, {version: "1.2"}, {version: "1.22"}]
    @hash = {version_b: "1.1", version_a: "1.11", version_c: "1.2", version_d: "1.22"}
  end

  def test_should_sort_enumerables_correctly
    assert_equal [*@array], [@array.to_args]
    
    assert_equal "1.2", @array.natural_sort[1]
    assert_equal "1.22", @array.natural_sort{|a,b| b <=> a}[0]
    assert_equal "1.2", @array.natural_sort_by{|x| x}[1]
    
    assert_equal([:version_c, "1.2"], @hash.natural_sort_by{|x| x[1]}[1])
    assert_equal([:version_c, "1.2"], @hash.natural_sort[1])
    #assert_equal([:version_d, "1.22"], @hash.natural_sort{|a,b| b[1] <=> a[1]}[0])

    #assert_equal({version: "1.2"}, @hash_array.natural_sort[1])
    #assert_equal({version: "1.22"}, @hash_array.natural_sort{|a,b| b[:version] <=> a[:version]}[0])
    #assert_equal({version: "1.2"}, @hash_array.natural_sort_by{|x| x[:version]}[1])
  end
end
