#!/usr/bin/env ruby -w

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yaml'
require 'minitest'

require 'rearmed'

require 'minitest/autorun'

class TestRearmed < MiniTest::Test
  def setup
    Minitest::Assertions.module_eval do
      alias_method :eql, :assert_equal
    end

    Rearmed.enabled_patches = {
      array: true,
      hash: true,
      object: true,
      string: true,
      date: true,
      enumerable: true,
      rails_3: true,
      rails_4: true,
      rails: true,
      minitest: true
    }
    require 'rearmed/apply_patches'
  end

  def test_string
    # Test String Methods
    str = '32'
    eql(str.valid_integer?, true)

    str = '32.2'
    eql(str.valid_integer?, false)

    str = '32a'
    eql(str.valid_integer?, false)

    str = '132.2'
    eql(str.valid_float?, true)

    str = '132.2.2'
    eql(str.valid_float?, false)

    str = '12.1a'
    eql(str.valid_float?, false)

    str = 'true'
    eql(str.to_bool, true)

    str = 'false'
    eql(str.to_bool, false)

    str = 'not true'
    assert_nil(str.to_bool)


    str = 'true'
    eql(Rearmed.to_bool(str), true)

    str = '12'
    eql(Rearmed.valid_integer?(str), true)

    str = '1.2'
    eql(Rearmed.valid_float?(str), true)
  end

  def test_date
    Date.now
  end

  def test_enumerable
    items = ['1.1', '1.11', '1.2']

    eql(items.natural_sort, ['1.1','1.2','1.11'])

    eql(items.natural_sort(reverse: true), ['1.11','1.2','1.1'])

    eql(Rearmed.natural_sort(items), ['1.1','1.2','1.11'])

    eql(Rearmed.natural_sort(items, reverse: true), ['1.11','1.2','1.1'])


    items = [{version: "1.1"}, {version: "1.11"}, {version: "1.2"}]
    
    eql(items.natural_sort_by{|x| x[:version]}, [{version: "1.1"}, {version: "1.2"}, {version: "1.11"}])
    
    eql(Rearmed.natural_sort_by(items){|x| x[:version]}, [{version: "1.1"}, {version: "1.2"}, {version: "1.11"}])


    # Only available on array and hash in Ruby 2.2.x or below
    array = [{foo: ['foo','bar']}, {test: 'thing'}]

    eql(array.dig(0, :foo, 1), 'bar')
    assert_nil(array.dig(0, :foo, 2))

    eql(Rearmed.dig(array, 1, :test), 'thing')
    assert_nil(Rearmed.dig(array, 1, :bar))

    hash = {a: {foo: ['bar']}, b: {c: 'c'}}
    
    eql(hash.dig(:a, :foo, 0), 'bar')
    eql(Rearmed.dig(hash, :b, :c), 'c')
  end

  def test_array
    array = [1,3,2,1,3,4,1]
    array.delete_first(3)
    eql(array, [1,2,1,3,4,1])

    array = [1,3,2,1,3,4,1]
    array.delete_first
    eql(array, [3,2,1,3,4,1])

    array = [1,3,2,1,3,4,1]
    array.delete_first{|x| x != 1}
    eql(array, [1,2,1,3,4,1])

    eql(array.not_empty?, true)
  end
  
  def test_hash
    hash = {foo: 'foo', bar: 'bar', other: 'other'}
    eql(hash.only(:foo, :bar), {foo: 'foo', bar: 'bar'})

    hash = {foo: 'foo', bar: 'bar', other: 'other'}
    hash.only!(:foo, :bar)
    eql(hash, {foo: 'foo', bar: 'bar'})

    hash = {foo: 'foo', bar: 'bar', other: 'other'}
    eql(Rearmed.hash_only(hash, :foo, :bar), {foo: 'foo', bar: 'bar'})

    hash = {foo: nil, bar: nil, other: 'other'}
    eql(hash.compact, {other: 'other'})
    eql(Rearmed.hash_compact(hash), {other: 'other'})

    hash = {foo: nil, bar: nil, other: 'other'}
    hash.compact!
    eql(hash, {other: 'other'})

    hash = {foo: :bar, bar: :foo}
    eql(hash.join, "foo: bar, bar: foo")
    eql(hash.join('___'), "foo: bar___bar: foo")
    eql(hash.join{|k,v| v}, "bar, foo")
    eql(hash.join('___'){|k,v| v}, "bar___foo")
    eql(Rearmed.hash_join(hash), "foo: bar, bar: foo")
    eql(Rearmed.hash_join(hash, '___'), "foo: bar___bar: foo")
    eql(Rearmed.hash_join(hash){|k,v| v}, "bar, foo")
    eql(Rearmed.hash_join(hash, '___'){|k,v| v}, "bar___foo")

    hash = {foo: :bar, bar: 'foo'}
    struct = hash.to_struct
    assert(struct.is_a?(Struct))
    eql(struct.foo, :bar)
    eql(struct.bar, 'foo')

    struct = Rearmed.hash_to_struct(hash)
    assert(struct.is_a?(Struct))
    eql(struct.foo, :bar)
    eql(struct.bar, 'foo')
  end

  def test_object
    str = 'test'
    eql(str.not_nil?, true)

    str = nil
    eql(str.not_nil?, false)

    str = false
    eql(str.not_nil?, true)

    str = 'test'
    eql(str.in?(['test','abc']), true)

    str = 'test'
    eql(str.in?(['abc','def']), false)

    str = 'test'
    eql(str.in?('test','abc'), true)

    str = 'test'
    eql(str.in?('abc','def'), false)

    str = 'test'
    eql(str.in?('a test string'), true)

    str = 'test'
    eql(str.in?('a real string'), false)
  end

end
