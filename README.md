# Rearmed Ruby
<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 

A collection of helpful methods for Enumerables, Arrays, Requiring, & Rails(not required)

### Rearmed Methods
```ruby
Rearmed.naturalize_str(my_string) # used in the natural sorting methods
Rearmed.recursive_require(my_folder_path) # all .rb files that are children of this folder
Rearmed.recursive_require_folder(my_folder_path) # alias of recursive_require
Rearmed.require_folder(my_fodler_path) # all .rb files in this folder only
```

### Object
```ruby
my_var.not_nil?
my_var.in?([1,2,3])
```

### Numeric
```ruby
-1.to_positive # => 1
1.to_positive # => 1
```

### String
```ruby
'123'.valid_integer?
'123.123'.valid_float?
'true'.to_bool
```

### Date
Date.now

### Enumerable Methods (Array, Hash, etc.)
```ruby
# Array Example
[1.1,1.11,1.2].natural_sort_by{|x| x} # => [1.1,1.2,1.11,1.22]
[1.1,1.11,1.2].natural_sort_by!{|x| x} # => [1.1,1.2,1.11,1.22]

# Hash Example
[{version: "1.1"}, {version: "1.11"}, {version: "1.2"}].natural_sort_by{|x| x[:version]} # => [{version: "1.1"}, {version: "1.2"}, {version: "1.11"}, {version: "1.22"}]
{version_b: "1.1", version_a: "1.11", "version_c": "1.2"}.natural_sort_by!{|x| x[1]} # => {version_b: "1.1", version_c: "1.2", "version_a": "1.11"}
```

### Array Methods
```ruby
[1.1, 1.11, 1.2].natural_sort
[1.1, 1.11, 1.2].find(1.11) # returns my_value if found
[1,2,1,2,1].index_all(1) # => [0,2,4]

array = [1,2,1,4,1]
array.delete_first(1) # => 1
puts array #=> [2,1,4,1]
my_var = 1
array.delete_first{|x| my_var == x} # => 1
puts array # => [2,4,1]
```

### String Methods
```ruby
"1.9".valid_float? # => true
"test".valid_float? # => false

"true".to_bool # => true
"false".to_bool # => false
```

### Rails Add-ons
```ruby
my_hash.only(:foo, :bar) # alias to slice
my_hash.only!(:foo, :bar) # alias to slice!
```

### Rails Method Backports
```ruby
# Rails 3.* & 4.0 
my_hash.compact
my_hash.compact!
Post.all # Now returns AR relation
Post.first.update_columns(a: 'foo', b: 'bar')
Post.pluck(:name, :id) # adds multi column pluck support ex. => [['first', 1], ['second', 2], ['third', 3]]
```

# Credits
Created by Weston Ganger - @westonganger

<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 
