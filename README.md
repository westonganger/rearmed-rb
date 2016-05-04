# Spreadsheet Architect
<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VKY8YAWAS5XRQ&lc=CA&item_name=Weston%20Ganger&item_number=rearmed_rb&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest" target="_blank" title="Buy Me A Coffee"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif" alt="Buy Me A Coffee"/></a>

```ruby
# Rearmed Methods

Rearmed.naturalize_str(my_string)

Rearmed.recursive_require(my_folder_path) # all .rb files that are children of this folder
Rearmed.recursive_require_folder(my_folder_path) # alias of recursive_require
Rearmed.require_folder(my_fodler_path) # all .rb files in this folder only


# Enumerable Methods (Array, Hash, etc.)
[1.1,1.11,1.2].natural_sort_by{|x| x} # => [1.1,1.2,1.11,1.22]
[{version: "1.1"}, {version: "1.11"}, {version: "1.2"}].natural_sort_by{|x| x[:version]} # => [{version: "1.1"}, {version: "1.2"}, {version: "1.11"}, {version: "1.22"}]
{version_b: "1.1", version_a: "1.11", "version_c": "1.2"}.natural_sort_by{|x| x[1]} # => {version_b: "1.1", version_c: "1.2", "version_a": "1.11"}


#Array Methods

[1.1,1.11,1.2].natural_sort
Array.find(my_value) # returns my_value if found


# Rails 4 Methods for use with Rails 3
Hash.compact
Hash.compact!
ArModel.all # Now returns AR relation
ar_relation.update_columns(a: 'foo', b: 'bar')
```


# Credits
Created by Weston Ganger - @westonganger

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VKY8YAWAS5XRQ&lc=CA&item_name=Weston%20Ganger&item_number=rearmed_rb&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest" target="_blank" title="Buy Me A Coffee"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif" alt="Buy Me A Coffee"/></a>
