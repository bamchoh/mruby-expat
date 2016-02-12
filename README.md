# mruby-expat   [![Build Status](https://travis-ci.org/bamchoh/mruby-expat.png?branch=master)](https://travis-ci.org/bamchoh/mruby-expat)

[![Join the chat at https://gitter.im/bamchoh/mruby-expat](https://badges.gitter.im/bamchoh/mruby-expat.svg)](https://gitter.im/bamchoh/mruby-expat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
XML Parser module for mruby using Expat that is XML Parser library by C. You can parse XML text from mruby application by using this module.

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
root = XmlParser.parse('
<root>
  <nodes counts="3">
    <node id="1">a</node>
    <node id="2">b</node>
    <node id="3">c</node>
  </nodes>
</root>')

p root.name #=> "root"

#
# find method for example
#
nodes = root.find("nodes")
p nodes.name #=> "nodes"
p nodes.attributes #=> {"counts" => "3"}

nodes.children.each do |child|
  p child.name #=> "node"
end

#
# find_all method for example
#
elems = root.find_all("node")
elems.each do |elem|
  p elem.name #=> "node"
  p elem.text #=> "a", "b", "c"
end

#
# find method with node and attributes
#
node = root.find("node", {"id"=>"2"})
p node.name #=> "node"
p node.attributes #=> {"id"=>"2"}
p node.text #=> "b"
```

## License
under the MIT License:
- see LICENSE file
