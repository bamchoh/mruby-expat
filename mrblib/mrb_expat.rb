class XmlParserError < StandardError; end

class XmlElement
  attr_accessor :name, :attributes, :parent, :texts, :children

  def initialize(name, attributes, parent)
    @name  = name
    @attributes = attributes
    @parent = parent
    @children = []
    @texts = []
  end

  def check(name, search_attrs)
    if(@name == name)
      if(search_attrs)
        if(search_attrs.all? { |k, v| @attributes[k] && (@attributes[k] == v) })
          yield
        end
      else
        yield
      end
    end
  end

  def check_children(name, search_attrs, method)
    if @children
      @children.each do |child|
        if child.respond_to?(method)
          yield child
        end
      end
      nil
    end
  end

  def find(name, search_attrs = nil)
    check(name, search_attrs) do
      return self
    end

    check_children(name, search_attrs, :find) do |child|
      ret = child.find(name, search_attrs)
      return ret if ret
    end
  end

  def find_all(name, search_attrs = nil, found = [])
    check(name, search_attrs) do
      found << self
    end

    check_children(name, search_attrs, :find_all) do |child|
      child.find_all(name, search_attrs, found)
    end

    found
  end

  def text
    @texts.first
  end
end

class XmlParser
  def self.parse(str)
    self.new.__sys_parse__(str)
  end

  private
  attr_accessor :root

  def __sys_start_element__(name, attrs)
    if @doc.nil?
      @root = @doc = XmlElement.new(name, attrs, nil)
    else
      elem = XmlElement.new(name, attrs, @doc)
      @doc.children << elem
      @doc = elem
    end
  end

  def __sys_end_element__(name)
    @doc = @doc.parent
  end

  def __sys_detect_text__(text)
    @doc.texts << text
  end
end
