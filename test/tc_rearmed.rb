#!/usr/bin/env ruby -w
require 'yaml'
require 'minitest'
require 'lib/rearmed.rb'

puts "sort_by: #{["1.1","1.11","1.2","1.22"].sort_by{|x| x}}"
puts "natural_sort_by: #{["1.1","1.11","1.2","1.22"].natural_sort_by{|x| Rearmed.naturalize_str(x)}}"

=begin

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestSpreadsheetArchitect < MiniTest::Test
  class Post
  end

  test "test_spreadsheet_options" do
    assert_equal([:name, :title, :content, :votes, :ranking], Post.spreadsheet_columns)
    assert_equal([:name, :title, :content, :votes, :created_at, :updated_at], OtherPost.column_names)
    assert_equal([:name, :title, :content], PlainPost.spreadsheet_columns)
  end
end
  
class TestToCsv < MiniTest::Test
  test "test_class_method" do
    p = Post.to_csv(spreadsheet_columns: [:name, :votes, :content, :ranking])
    assert_equal(true, p.is_a?(String))
  end
  test 'test_chained_method' do
    p = Post.order("name asc").to_csv(spreadsheet_columns: [:name, :votes, :content, :ranking])
    assert_equal(true, p.is_a?(String))
  end
end

class TestToOds < MiniTest::Test
  test 'test_class_method' do
    p = Post.to_ods(spreadsheet_columns: [:name, :votes, :content, :ranking])
    assert_equal(true, p.is_a?(String))
  end
  test 'test_chained_method' do
    p = Post.order("name asc").to_ods(spreadsheet_columns: [:name, :votes, :content, :ranking])
    assert_equal(true, p.is_a?(String))
  end
end
=end
