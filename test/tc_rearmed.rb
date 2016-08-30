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
    eql(str.to_bool, nil)


    # Test Rearmed methods (just cause really)
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
    eql(array.dig(0, :foo, 2), nil)

    eql(Rearmed.dig(array, 1, :test), 'thing')
    eql(Rearmed.dig(array, 1, :bar), nil)

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
    eql(Rearmed.only(hash, :foo, :bar), {foo: 'foo', bar: 'bar'})


    hash = {foo: nil, bar: nil, other: 'other'}
    eql(hash.compact, {other: 'other'})

    hash = {foo: nil, bar: nil, other: 'other'}
    hash.compact!
    eql(hash, {other: 'other'})
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

  def test_minitest
    str = 'first'
    assert_changed "str" do
      str = 'second'
    end

    str = 'first'
    assert_changed ->{ str } do
      str = 'second'
    end

    name = 'first'
    assert_changed lambda{ name } do
      name = 'second'
    end

    name = 'first'
    assert_not_changed 'name' do
      name = 'first'
    end

    name = 'first'
    assert_not_changed ->{ name } do
      name = 'first'
    end

    name = 'first'
    assert_not_changed lambda{ name } do
      name = 'first'
    end
  end

  def test_general_rails
    # THE MOST IMPORTANT TESTS HERE WOULD BE dedupe, reset_auto_increment, reset_table
    
    #Post.pluck_to_hash(:name, :category, :id)
    #Post.pluck_to_struct(:name, :category, :id)

    #Post.find_or_create(name: 'foo', content: 'bar') # use this instead of the super confusing first_or_create method
    #Post.find_or_create!(name: 'foo', content: 'bar')

    #Post.find_duplicates # return active record relation of all records that have duplicates
    #Post.find_duplicates(:name) # find duplicates based on the name attribute
    #Post.find_duplicates([:name, :category]) # find duplicates based on the name & category attribute
    #Post.find_duplicates(name: 'A Specific Name')

    #Post.reset_table # delete all records from table and reset autoincrement column (id), works with mysql/mariadb/postgresql/sqlite
    ## or with options
    #Post.reset_table(delete_method: :destroy) # to ensure all callbacks are fired

    #Post.reset_auto_increment # reset mysql/mariadb/postgresql/sqlite auto-increment column, if contains records then defaults to starting from next available number
    ## or with options
    #Post.reset_auto_increment(value: 1, column: :id) # column option is only relevant for postgresql

    #Post.find_in_relation_batches # this returns a relation instead of an array
    #Post.find_relation_each # this returns a relation instead of an array
  end

  def test_rails_3
    #my_hash.compact
    #my_hash.compact!
    #Post.all # Now returns AR relation
    #Post.first.update_columns(a: 'foo', b: 'bar')
    #Post.pluck(:name, :id) # adds multi column pluck support ex. => [['first', 1], ['second', 2], ['third', 3]]
  end

  def test_rails_4
    #Post.where(name: 'foo').or.where(content: 'bar')
    #Post.where(name: 'foo').or.my_custom_scope
    #Post.where(name: 'foo').or(Post.where(content: 'bar'))
    #Post.where(name: 'foo).or(content: 'bar')

    #= link_to 'Delete', post_path(post), method: :delete, confirm: "Are you sure you want to delete this post?" 
    # returns to rails 3 behaviour of allowing confirm attribute as well as data-confirm
  end
end
