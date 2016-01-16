# mruby-expat   [![Build Status](https://travis-ci.org/bamchoh/mruby-expat.png?branch=master)](https://travis-ci.org/bamchoh/mruby-expat)
Expat class
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'bamchoh/mruby-expat'
end
```
## example
```ruby
p Expat.hi
#=> "hi!!"
t = Expat.new "hello"
p t.hello
#=> "hello"
p t.bye
#=> "hello bye"
```

## License
under the MIT License:
- see LICENSE file
