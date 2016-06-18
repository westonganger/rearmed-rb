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
    hash_compact: false,
    pluck: false,
    update_columns: false,
    all: false
  },
  rails: {
    pluck_to_hash: false,
    pluck_to_struct: false,
    find_relation_each: false,
    find_in_relation_batches: false,
  },
  string: {
    to_bool: false,
    valid_integer: false,
    valid_float: false
  },
  hash: {
    only: false,
    dig: false
  },
  array: {
    dig: false,
    delete_first: false
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
my_var.in?([1,2,3])
my_var.in?(1,2,3) # or with splat arguments
```

### String
```ruby
'123'.valid_integer?
# or without monkey patch: Rearmed.valid_integer?('123')

'123.123'.valid_float? 
# or without monkey patch: Rearmed.valid_float?('123')

'true'.to_bool 
# or without monkey patch: Rearmed.to_bool('true')
```

### Date
```ruby
Date.now
```

### Enumerable Methods (Array, Hash, etc.)
```ruby
items = ['1.1', '1.11', '1.2']
items.natural_sort 
items.natural_sort(reverse: true) # because natural_sort does not accept a block
# or without monkey patch: Rearmed.natural_sort(items) or Rearmed.natural_sort(items, reverse: true)

items = ['1.1', '1.11', '1.2']
items.natural_sort{|a,b| b <=> a} 
# or without monkey patch: Rearmed.natural_sort(items){|a,b| b <=> a}

items = [{version: "1.1"}, {version: "1.11"}, {version: "1.2"}]
items.natural_sort_by{|x| x[:version]} 
# or without monkey patch: Rearmed.natural_sort_by(items){|x| x[:version]}

# Only available on array and hash in Ruby 2.2.x or below
items = [{foo: ['foo','bar']}, {test: 'thing'}]
items.dig(1, :foo, 2) # => 'bar'
# or without monkey patch: Rearmed.dig(items){|x| x[:version]}
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
```

### Hash Methods
```ruby
hash = {foo: 'foo', bar: 'bar', other: 'other'}
hash.only(:foo, :bar) # => {foo: 'foo'}
# or without monkey patch: Rearmed.only(hash, :foo, :bar)

hash.only!(:foo, :bar)
```

### Rails

##### Additional ActiveRecord Methods
```ruby
Post.all.pluck_to_hash(:name, :category, :id)
Post.all.pluck_to_struct(:name, :category, :id)
Post.find_in_relation_batches # this returns a relation instead of an array
Post.find_relation_each # this returns a relation instead of an array
```

##### Rails 3.x Backports
```ruby
my_hash.compact
my_hash.compact!
Post.all # Now returns AR relation
Post.first.update_columns(a: 'foo', b: 'bar')
Post.pluck(:name, :id) # adds multi column pluck support ex. => [['first', 1], ['second', 2], ['third', 3]]
```


##### Rails 4.x Backports
```ruby
Post.where(name: 'foo').or.where(content: 'bar')
= link_to 'Delete', post_path(post), method: :delete, confirm: "Are you sure you want to delete this post?" #returns rails 3 behaviour of allowing confirm attribute as well as data-confirm
```

# Credits
Created by Weston Ganger - @westonganger

<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 
