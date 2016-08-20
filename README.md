# Rearmed Ruby
<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 

A collection of helpful methods and monkey patches for Objects, Strings, Enumerables, Arrays, Hash, Dates, & Rails

The difference between this library and others is that all monkey patching is performed in an opt-in way because you shouldnt be using methods you dont know about anyways. 

For applicable methods I have placed the implementation inside the Rearmed module so if you don't like monkey patching or are working on the project with a team then you can use these methods instead. You can see how to use this implementation below the relevant methods here in the readme.

```ruby
# Gemfile

gem 'rearmed'
```

Run `rails g rearmed:setup` to create a settings files in `config/initializers/rearmed.rb` where you can opt-in to the monkey patches available in the library. Set these values to true if you want to enable the applicable monkey patch.

```ruby
# config/initializers/rearmed.rb

Rearmed.enabled_patches = {
  rails_4: {
    or: false,
    link_to_confirm: false
  },
  rails_3: {
    pluck: false,
    update_columns: false,
    all: false
  },
  rails: {
    pluck_to_hash: false,
    pluck_to_struct: false,
    find_or_create: false,
    reset_table: false,
    reset_auto_increment: false,
    dedupe: false,
    find_relation_each: false,
    find_in_relation_batches: false,
  },
  string: {
    valid_integer: false,
    valid_float: false,
    to_bool: false,
    starts_with: false,
    begins_with: false,
    ends_with: false
  },
  hash: {
    only: false,
    dig: false,
    compact: false
  },
  array: {
    dig: false,
    delete_first: false,
    not_empty: false
  },
  enumerable: {
    natural_sort: false,
    natural_sort_by: false
  },
  object: {
    in: false,
    not_nil: false
  },
  date: {
    now: false
  }
}

require 'rearmed/apply_patches'
```

### Object
```ruby
my_var.not_nil?

# Only for non-Rails environments, as Rails already has this method
my_var.in?([1,2,3])
my_var.in?(1,2,3) # or with splat arguments
```

### String
```ruby
'123'.valid_integer?
# or without monkey patch: Rearmed.valid_integer?('123')

'123.123'.valid_float? 
# or without monkey patch: Rearmed.valid_float?('123.123')

'true'.to_bool 
# or without monkey patch: Rearmed.to_bool('true')

# alias of start_with? and end_with? to have more sensible method names
'foo'.starts_with?('fo') # => true
'foo'.begins_with?('fo') # => true
'bar'.ends_with?('ar') # => true
```

### Date
```ruby
Date.now
```

### Enumerable Methods (Array, Hash, etc.)
```ruby
items = ['1.1', '1.11', '1.2']
items.natural_sort 
items.natural_sort(reverse: true) # because natural_sort does not accept a block, accepting PR's on this
# or without monkey patch: Rearmed.natural_sort(items) or Rearmed.natural_sort(items, reverse: true)

items = [{version: "1.1"}, {version: "1.11"}, {version: "1.2"}]
items.natural_sort_by{|x| x[:version]} 
# or without monkey patch: Rearmed.natural_sort_by(items){|x| x[:version]}

# Only available on array and hash in Ruby 2.2.x or below
items = [{foo: ['foo','bar']}, {test: 'thing'}]
items.dig(0, :foo, 1) # => 'bar'
# or without monkey patch: Rearmed.dig(items, 0, :foo, 1)
```

### Array Methods
```ruby
array = [1,2,1,4,1]
array.delete_first(1) # => 1
puts array #=> [2,1,4,1]
array.delete_first{|x| 1 == x} # => 1
puts array # => [2,4,1]
array.delete_first # => 2
puts array # => [4,1]

array.not_empty? # => true
```

### Hash Methods
```ruby
hash = {foo: 'foo', bar: 'bar', other: 'other'}
hash.only(:foo, :bar) # => {foo: 'foo'}
# or without monkey patch: Rearmed.only(hash, :foo, :bar)

hash.only!(:foo, :bar)

my_hash.compact
my_hash.compact!
```

### Rails

##### Additional ActiveRecord Methods
Note: All methods which involve deletion are compatible with Paranoia & ActsAsParanoid

```ruby
Post.pluck_to_hash(:name, :category, :id)
Post.pluck_to_struct(:name, :category, :id)

Post.find_or_create(name: 'foo', content: 'bar') # use this instead of the super confusing first_or_create method
Post.find_or_create!(name: 'foo', content: 'bar')

Post.reset_table # delete all records from table and reset autoincrement column (id), works with mysql/mariadb/postgresql/sqlite
# or with options
Post.reset_table(delete_method: :destroy) # to ensure all callbacks are fired

Post.reset_auto_increment # reset mysql/mariadb/postgresql/sqlite auto-increment column, if contains records then defaults to starting from next available number
# or with options
Post.reset_auto_increment(value: 1, column: :id) # column option is only relevant for postgresql

Post.dedupe # remove all duplicate records, defaults to all of the models column_names except timestamps
# or with options
Post.dedupe(delete_method: :destroy) # to ensure all callbacks are fired
Post.dedupe(columns: [:name, :content, :category_id]
Post.dedupe(skip_timestamps: false) # skip timestamps defaults to true (created_at, updated_at, deleted_at)
Post.dedupe(keep: :last) # Keep the last duplicate instead of the first duplicate by default

Post.find_in_relation_batches # this returns a relation instead of an array
Post.find_relation_each # this returns a relation instead of an array
```

##### Rails 4.x Backports
```ruby
Post.where(name: 'foo').or.where(content: 'bar')
Post.where(name: 'foo').or.my_custom_scope
Post.where(name: 'foo').or(Post.where(content: 'bar'))
Post.where(name: 'foo).or(content: 'bar')

= link_to 'Delete', post_path(post), method: :delete, confirm: "Are you sure you want to delete this post?" 
# returns to rails 3 behaviour of allowing confirm attribute as well as data-confirm
```

##### Rails 3.x Backports
```ruby
Post.all # Now returns AR relation
Post.first.update_columns(a: 'foo', b: 'bar')
Post.pluck(:name, :id) # adds multi column pluck support ex. => [['first', 1], ['second', 2], ['third', 3]]

my_hash.compact # See Hash methods above
my_hash.compact!
```

# Contributing / Todo
If you want to request a method please raise an issue and we can discuss the implementation. 

If you want to contribute here are a couple of things you could do:

- Add Tests for Rails methods
- Get the `natural_sort` method to accept a block


# Credits
Created by Weston Ganger - @westonganger

<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 
