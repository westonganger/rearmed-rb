# Rearmed Ruby
<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 

A collection of helpful methods for Enumerables, Arrays, Requiring, & Rails(not required)

```ruby
### Rearmed Methods
Rearmed.naturalize_str(my_string) # used in the natural sorting methods
Rearmed.recursive_require(my_folder_path) # all .rb files that are children of this folder
Rearmed.recursive_require_folder(my_folder_path) # alias of recursive_require
Rearmed.require_folder(my_fodler_path) # all .rb files in this folder only


### Enumerable Methods (Array, Hash, etc.)
[1.1,1.11,1.2].natural_sort_by{|x| x} # => [1.1,1.2,1.11,1.22]
[{version: "1.1"}, {version: "1.11"}, {version: "1.2"}].natural_sort_by{|x| x[:version]} # => [{version: "1.1"}, {version: "1.2"}, {version: "1.11"}, {version: "1.22"}]
{version_b: "1.1", version_a: "1.11", "version_c": "1.2"}.natural_sort_by{|x| x[1]} # => {version_b: "1.1", version_c: "1.2", "version_a": "1.11"}


### Array Methods
[1.1, 1.11, 1.2].natural_sort
[1.1, 1.11, 1.2].find(1.11) # returns my_value if found


### Rails 4 Methods for use with Rails 3
my_hash.compact
my_hash.compact!
ArModel.all # Now returns AR relation
ar_relation.update_columns(a: 'foo', b: 'bar')
```


# Credits
Created by Weston Ganger - @westonganger

<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 
