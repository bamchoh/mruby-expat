##
## Expat Test
##

test_xml_01 = '
<root>
  <tests>
    start
    <test>1</test>
    <test></test>
    <test />
    <test>3</test>
    end
  </tests>
  <properties>
    <property name="start">abc</property>
    <property 属性1="値1" options="1 2 3">あいう</property>
    <property name="class" options="default" />
    <property name="class" options="id=1" />
    <property name="class" options="id=2" />
    <property name="class" options="id=3" />
    <property name="end" >def</property>
  </properties>
  <あいう><いろは>ほへと</いろは></あいう>
</root>'

assert("XmlParser#parse(root)") do
  t = XmlParser.parse test_xml_01
  assert_equal(XmlElement, t.class)
  assert_equal("root", t.name)
  assert_equal({}, t.attributes)
  assert_nil(t.parent)
  assert_not_equal(nil, t.children)
  assert_equal(3, t.children.size)
  assert_equal(["\n  ", "\n  ", "\n  ", "\n"], t.texts)
  assert_equal("\n  ", t.text)
end

assert("XmlParser#parse(tests)") do
  root = XmlParser.parse(test_xml_01)
  t = root.find("tests")
  assert_equal(XmlElement, t.class)
  assert_equal("tests", t.name)
  assert_equal({}, t.attributes)
  assert_equal(root, t.parent)
  assert_not_equal(nil, t.children)
  assert_equal(4, t.children.size)
  assert_equal(["\n    start\n    ", "\n    ", "\n    ", "\n    ", "\n    end\n  "], t.texts)
  assert_equal("\n    start\n    ", t.text)
end

assert("XmlParser#parse(tests/test 1)") do
  tests = XmlParser.parse(test_xml_01).find("tests")
  t = tests.find("test")
  assert_equal(XmlElement, t.class)
  assert_equal("test", t.name)
  assert_equal({}, t.attributes)
  assert_equal(tests, t.parent)
  assert_equal([], t.children)
  assert_equal(["1"], t.texts)
  assert_equal("1", t.text)
end

assert("XmlParser#parse(tests/test 2)") do
  tests = XmlParser.parse(test_xml_01).find("tests")
  t = tests.find_all("test")[1]
  assert_equal(XmlElement, t.class)
  assert_equal("test", t.name)
  assert_equal({}, t.attributes)
  assert_equal(tests, t.parent)
  assert_equal([], t.children)
  assert_equal([], t.texts)
  assert_equal(nil, t.text)
end

assert("XmlParser#parse(tests/test no any children)") do
  tests = XmlParser.parse(test_xml_01).find("tests")
  t = tests.find_all("test")[2]
  assert_equal(XmlElement, t.class)
  assert_equal("test", t.name)
  assert_equal({}, t.attributes)
  assert_equal(tests, t.parent)
  assert_equal([], t.children)
  assert_equal([], t.texts)
  assert_equal(nil, t.text)
end

assert("XmlParser#parse(properties 1st child)") do
  parent = XmlParser.parse(test_xml_01).find("properties")
  t = parent.find_all("property")[0]
  assert_equal(XmlElement, t.class)
  assert_equal("property", t.name)
  assert_equal({"name"=>"start"}, t.attributes)
  assert_equal(parent, t.parent)
  assert_equal([], t.children)
  assert_equal(["abc"], t.texts)
  assert_equal("abc", t.text)
end

assert("XmlParser#parse(properties 2nd child)") do
  # <property 属性1="name" options="1 2 3">test</property>
  parent = XmlParser.parse(test_xml_01).find("properties")
  t = parent.find_all("property")[1]
  assert_equal(XmlElement, t.class)
  assert_equal("property", t.name)
  assert_equal({"options"=>"1 2 3", "属性1"=>"値1"}, t.attributes)
  assert_equal(parent, t.parent)
  assert_equal([], t.children)
  assert_equal(["あいう"], t.texts)
  assert_equal( "あいう", t.text)
end

assert("XmlParser#parse(properties 3rd child)") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01).find("properties")
  t = parent.find_all("property")[2]
  assert_equal(XmlElement, t.class)
  assert_equal("property", t.name)
  assert_equal({"options"=>"default", "name"=>"class"}, t.attributes)
  assert_equal(parent, t.parent)
  assert_equal([], t.children)
  assert_equal([], t.texts)
  assert_equal(nil, t.text)
end

assert("XmlParser#parse(あいう/いろは)") do
  # <あいう><いろは>ほへと</いろは></あいう>
  parent = XmlParser.parse(test_xml_01).find("あいう")
  t = parent.find("いろは")
  assert_equal(XmlElement, t.class)
  assert_equal("いろは", t.name)
  assert_equal({}, t.attributes)
  assert_equal(parent, t.parent)
  assert_equal([], t.children)
  assert_equal(["ほへと"], t.texts)
  assert_equal( "ほへと", t.text)
end

assert("XmlParser#parse parse error") do
  assert_raise(XmlParserError) { XmlParser.parse('<root>') }
end

assert("XmlParser#parse CDATA") do
  t = XmlParser.parse('<root><![CDATA[x<0]]></root>')
  assert_equal([], t.children)
  assert_equal("x<0", t.text)
end

assert("#find args node only") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  t = parent.find("property")
  assert_equal(XmlElement, t.class)
  assert_equal("property", t.name)
  assert_equal({"name"=>"start"}, t.attributes)
end

assert("#find with node and 1 attribute") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  t = parent.find("property", {"name" => "class"})
  assert_equal(XmlElement, t.class)
  assert_equal("property", t.name)
  assert_equal({"name"=>"class", "options"=>"default"}, t.attributes)
end

assert("#find with node and 2 attribute") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  t = parent.find("property", {"name" => "class", "options" => "id=2"})
  assert_equal(XmlElement, t.class)
  assert_equal("property", t.name)
  assert_equal({"name"=>"class", "options"=>"id=2"}, t.attributes)
end

assert("#find with node only, but there are no any matching node") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  assert_nil(parent.find("node"))
end

assert("#find with node and 1 attribute, but there are no any matching node") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  assert_nil parent.find("property", {"node"=>nil})
end

assert("#find with node and 2 attribute, but there are no any matching node") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  assert_nil parent.find("property", {"name"=>"class", "options" => nil})
end

assert("#find args node only") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  t = parent.find_all("property")
  assert_equal(7, t.size)
end

assert("#find with node and 1 attribute") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  t = parent.find_all("property", {"name" => "class"})
  assert_equal(4, t.size)
end

assert("#find with node and 2 attribute") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  t = parent.find_all("property", {"name" => "class", "options" => "id=2"})
  assert_equal(1, t.size)
end

assert("#find with node only, but there are no any matching node") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  assert_equal([], parent.find_all("node"))
end

assert("#find with node and 1 attribute, but there are no any matching node") do
  # <property name="class" options="default" />
  parent = XmlParser.parse(test_xml_01)
  assert_equal([], parent.find_all("property", {"node"=>nil}))
end

assert("#find with node and 2 attribute, but there are no any matching node") do
  # <property name="class" options="default" />
  root = XmlParser.parse(test_xml_01)
  assert_equal([], root.find_all("property", {"name"=>"class", "options" => nil}))
end

