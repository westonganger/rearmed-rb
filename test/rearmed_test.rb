#!/usr/bin/env ruby -w

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'minitest'
require 'minitest/autorun'

Minitest::Assertions.module_eval do
  alias_method :eql, :assert_equal
end

require 'rearmed'

Rearmed.enabled_patches = :all
Rearmed.apply_patches!

class RearmedTest < MiniTest::Test
  def setup
  end

  def teardown
  end

  def test_string_valid_integer?
    str = '32'
    eql(str.valid_integer?, true)

    str = '32.2'
    eql(str.valid_integer?, false)

    str = '32a'
    eql(str.valid_integer?, false)

    str = '12'
    eql(Rearmed::String.valid_integer?(str), true)

    assert_raises TypeError do
      Rearmed::String.valid_integer?(1)
    end
  end

  def test_string_valid_integer?
    str = '132.2'
    eql(str.valid_float?, true)

    str = '132.2.2'
    eql(str.valid_float?, false)

    str = '12.1a'
    eql(str.valid_float?, false)

    str = '1.2'
    eql(Rearmed::String.valid_float?(str), true)

    assert_raises TypeError do
      Rearmed::String.valid_float?(1)
    end
  end

  def test_string_to_bool
    str = 'true'
    eql(str.to_bool, true)

    str = 'false'
    eql(str.to_bool, false)

    str = 'not true'
    assert_nil(str.to_bool)

    str = 'true'
    eql(Rearmed::String.to_bool(str), true)

    assert_raises TypeError do
      Rearmed::String.to_bool(1)
    end
  end

  def test_string_casecmp?
    str1 = 'foo'

    str2 = 'foo'
    eql(str1.casecmp?(str2), true)

    str2 = 'FOO'
    eql(str1.casecmp?(str2), true)

    str2 = 'foobar'
    eql(str1.casecmp?(str2), false)

    str2 = 'fo'
    eql(str1.casecmp?(str2), false)

    str2 = true
    eql(str1.casecmp?(str2), nil)

    str2 = 'foo'
    eql(Rearmed::String.casecmp?(str1, str2), true)

    assert_raises TypeError do
      Rearmed::String.casecmp?(1, 'foo')
    end
  end
  
  def test_string_match?
    assert_equal 'hello'.match?('he'), true
    assert_equal 'hello'.match?('he', 1), false
    assert_equal 'hello'.match?('o'), true
    assert_equal 'hello'.match?('ol'), false
    assert_equal 'hello'.match?('(.)'), true
    assert_equal 'hello'.match?(/(.)/), true
    assert_equal 'hello'.match?('xx'), false
  end

  def test_date_now
    assert_equal Date.now, Date.today
  end

  def test_enumerable_natural_sort
    items = ['1.1', '1.11', '1.2']
    eql(items.natural_sort, ['1.1','1.2','1.11'])
    eql(items.natural_sort(reverse: true), ['1.11','1.2','1.1'])
    eql(Rearmed::Enumerable.natural_sort(items), ['1.1','1.2','1.11'])
    eql(Rearmed::Enumerable.natural_sort(items, reverse: true), ['1.11','1.2','1.1'])

    assert_raises TypeError do
      Rearmed::Enumerable.natural_sort(1)
    end
  end

  def test_enumerable_natural_sort_by
    items = [{version: "1.1"}, {version: "1.11"}, {version: "1.2"}]
    eql(items.natural_sort_by{|x| x[:version]}, [{version: "1.1"}, {version: "1.2"}, {version: "1.11"}])
    eql(Rearmed::Enumerable.natural_sort_by(items){|x| x[:version]}, [{version: "1.1"}, {version: "1.2"}, {version: "1.11"}])

    assert_raises TypeError do
      Rearmed::Enumerable.natural_sort_by(1)
    end
  end

  def test_enumerable_select_map
    items = [0, 1, 2, 3, nil, false]
    eql(items.select_map{|x| x}, [0,1,2,3])
    eql(Rearmed::Enumerable.select_map(items){|x| x}, [0,1,2,3])

    assert items.select_map.is_a?(Enumerator)
    assert Rearmed::Enumerable.select_map(items).is_a?(Enumerator)

    assert_raises TypeError do
      Rearmed::Enumerable.select_map(1)
    end
  end

  def test_array_delete_first
    array = [1,3,2,1,3,4,1]
    array.delete_first(3)
    eql(array, [1,2,1,3,4,1])

    array = [1,3,2,1,3,4,1]
    array.delete_first
    eql(array, [3,2,1,3,4,1])

    array = [1,3,2,1,3,4,1]
    array.delete_first{|x| x != 1}
    eql(array, [1,2,1,3,4,1])
  end

  def test_array_not_empty?
    eql([nil].not_empty?, true)
    eql([].not_empty?, false)
  end

  def test_array_dig
    array = [{foo: ['foo','bar']}, {test: 'thing'}]
    eql(array.dig(0, :foo, 1), 'bar')
    assert_nil(array.dig(0, :foo, 2))
    eql(Rearmed.dig(array, 1, :test), 'thing')
    assert_nil(Rearmed.dig(array, 1, :bar))

    assert_raises TypeError do
      Rearmed.dig(1)
    end
  end
  
  def test_hash_only
    hash = {foo: 'foo', bar: 'bar', other: 'other'}

    eql(hash.only(:foo, :bar), {foo: 'foo', bar: 'bar'})

    eql(Rearmed::Hash.only(hash, :foo, :bar), {foo: 'foo', bar: 'bar'})

    assert_raises TypeError do
      Rearmed::Hash.only(1)
    end

    hash.only!(:foo, :bar)
    eql(hash, {foo: 'foo', bar: 'bar'})
  end

  def test_has_compact
    hash = {foo: nil, bar: nil, other: 'other'}

    eql(hash.compact, {other: 'other'})
    eql(Rearmed::Hash.compact(hash), {other: 'other'})

    assert_raises TypeError do
      Rearmed::Hash.compact(1)
    end

    hash.compact!
    eql(hash, {other: 'other'})
  end

  def test_hash_join
    hash = {foo: :bar, bar: :foo}

    eql(hash.join, "foo: bar, bar: foo")
    eql(hash.join('___'), "foo: bar___bar: foo")
    eql(hash.join{|k,v| v}, "bar, foo")
    eql(hash.join('___'){|k,v| v}, "bar___foo")
    eql(Rearmed::Hash.join(hash), "foo: bar, bar: foo")
    eql(Rearmed::Hash.join(hash, '___'), "foo: bar___bar: foo")
    eql(Rearmed::Hash.join(hash){|k,v| v}, "bar, foo")
    eql(Rearmed::Hash.join(hash, '___'){|k,v| v}, "bar___foo")

    assert_raises TypeError do
      Rearmed::Hash.join(1)
    end
  end

  def test_hash_to_struct
    hash = {foo: :bar, bar: :foo}

    struct = hash.to_struct
    assert(struct.is_a?(Struct))
    eql(struct.foo, :bar)
    eql(struct.bar, :foo)

    struct = Rearmed::Hash.to_struct(hash)
    assert(struct.is_a?(Struct))
    eql(struct.foo, :bar)
    eql(struct.bar, :foo)

    assert_raises TypeError do
      Rearmed::Hash.to_struct(1)
    end
  end

  def test_hash_dig
    hash = {a: {foo: ['bar']}, b: {c: 'c'}}
    eql(hash.dig(:a, :foo, 0), 'bar')
    eql(Rearmed.dig(hash, :b, :c), 'c')

    assert_raises TypeError do
      Rearmed.dig(1)
    end
  end

  def test_object_not_nil?
    str = nil
    eql(str.not_nil?, false)

    str = false
    eql(str.not_nil?, true)

    str = 'test'

    eql(str.not_nil?, true)
  end

  def test_object_in?
    str = 'test'

    eql(str.in?(['test','abc']), true)
    eql(str.in?(['abc','def']), false)
    eql(str.in?('test','abc'), true)
    eql(str.in?('abc','def'), false)
    eql(str.in?('a test string'), true)
    eql(str.in?('a real string'), false)
  end

  def test_object_true?
    assert_equal true.true?, true
    assert_equal false.true?, false
    assert_equal nil.true?, false
    assert_equal 'string'.true?, false
    assert_equal :symbol.true?, false
    assert_equal [].true?, false
    hash = {}
    assert_equal hash.true?, false
  end

  def test_object_false?
    assert_equal false.false?, true
    assert_equal true.false?, false
    assert_equal nil.false?, false
    assert_equal 'string'.false?, false
    assert_equal :symbol.false?, false
    assert_equal [].false?, false
    hash = {}
    assert_equal hash.true?, false
  end

  def test_object_bool?
    assert_equal true.bool?, true
    assert_equal false.bool?, true
    assert_equal nil.bool?, false
    assert_equal 'string'.bool?, false
    assert_equal :symbol.bool?, false
    assert_equal 1.bool?, false
    assert_equal 0.bool?, false
  end

  def test_integer_length
    assert_equal 1000.length, 4
    assert_equal (-1000).length, 4

    assert_raises NoMethodError do
      1000.0.length
    end
  end

  def test_enabled_patches
    Rearmed.instance_variable_set(:@applied, false)

    default = Rearmed.const_get(:DEFAULT_PATCHES)

    Rearmed.enabled_patches = nil
    assert_equal Rearmed.enabled_patches, default

    Rearmed.enabled_patches = {}
    assert_equal Rearmed.enabled_patches, default

    Rearmed.enabled_patches = :all
    assert_equal Rearmed.enabled_patches, :all

    Rearmed.enabled_patches = {array: true, foo: :foo, hash: nil, enumerable: false, date: {test: :test}}
    assert_equal Rearmed.enabled_patches, default.merge({array: true, date: {test: :test}})

    [true, false, [], '', 1, :foo, Rearmed].each do |x|
      assert_raises TypeError do
        Rearmed.enabled_patches = x
      end

      unless x.bool?
        assert_raises TypeError do
          Rearmed.enabled_patches = {array: x}
        end
      end
    end
  end

end
