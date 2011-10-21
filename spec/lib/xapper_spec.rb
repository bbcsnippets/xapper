require 'spec_helper'

describe Xapper::Mapper do

  before do
    @mapper = Xapper::Mapper.new
  end

  describe '#map' do

    it 'should map xml node values' do
      xml = %q{
        <?xml version="1.0" encoding="UTF-8"?>
        <foo>
          <bar>Hello world</bar>
          <baz>Goodbye world</baz>
        </foo>
      }
      @mapper.mappings = {
        :bar => '/foo/bar',
        :baz => '/foo/baz'
      }
      data = @mapper.map xml
      data[:bar].should == 'Hello world'
      data[:baz].should == 'Goodbye world'
    end

    it 'should map xml attribute values' do
      xml = %q{
        <?xml version="1.0" encoding="UTF-8"?>
        <foo>
          <bar text="Hello world" />
          <baz text="Goodbye world" />
        </foo>
      }
      @mapper.mappings = {
        :bar => '/foo/bar/@text',
        :baz => '/foo/baz/@text'
      }
      data = @mapper.map xml
      data[:bar].should == 'Hello world'
      data[:baz].should == 'Goodbye world'
    end

    it 'should map the result of a proc object if given, by passing currnent xml context as value' do
      xml = %q{
        <?xml version="1.0" encoding="UTF-8"?>
        <foo>
          <bar attr="BAR1">Text value</bar>
          <bar attr="BAR2">Text value</bar>
        </foo>
      }
      @mapper.mappings = {
        :bar => {
          :attributes => lambda do |xml|
            xml.xpath('//bar').map { |node| node.attribute('attr') }.join(',')
          end
        }
      }
      data = @mapper.map xml
      data[:bar][:attributes].should == 'BAR1,BAR2'

    end

    it 'should map a node to nil if it does not exist' do
      xml = %q{
        <?xml version="1.0" encoding="UTF-8"?>
        <foo><bar /></foo>
      }
      @mapper.mappings = {
        :bar => "/foo/bar/@attr",
        :baz => "/foo/baz"
      }
      data = @mapper.map xml
      data[:bar].should == nil
      data[:baz].should == nil
    end

    it 'should map an multiple xml elements to an array' do
      xml = %q{
        <?xml version="1.0" encoding="UTF-8"?>
        <foo>
          <bar>
            <baz attr="Attr value 1">Text value 1</bar>
          </bar>
          <bar>
            <baz attr="Attr value 2">Text value 2</bar>
          </bar>
        </foo>
      }
      @mapper.mappings = {
        :bar => ['/foo/bar', {
          :baz => {
            :attr => 'baz/@attr',
            :text => 'baz'
          }
        }]
      }
      data = @mapper.map xml
      data[:bar].size.should == 2
      data[:bar][0][:baz][:attr].should == "Attr value 1"
      data[:bar][0][:baz][:text].should == "Text value 1"
      data[:bar][1][:baz][:attr].should == "Attr value 2"
      data[:bar][1][:baz][:text].should == "Text value 2"
    end

    it 'should map into a nested hash' do
      xml = %q{
        <?xml version="1.0" encoding="UTF-8"?>
        <foo>
          <bar attr="Attr value">Text value</bar>
          <baz attr="Attr value">Text value</bar>
        </foo>
      }
      @mapper.mappings = {
        :bar => {
          :attr => '/foo/bar/@attr',
          :text => '/foo/bar'
        },
        :baz => {
          :attr => '/foo/baz/@attr',
          :text => '/foo/baz'
        }
      }
      data = @mapper.map xml
      data[:bar][:attr].should == 'Attr value'
      data[:bar][:text].should == 'Text value'
      data[:baz][:attr].should == 'Attr value'
      data[:baz][:text].should == 'Text value'
    end

  end

  it "should map namespaces correctly" do

    xml = %q{
      <root xmlns:h="http://www.w3.org/TR/html4/" xmlns:f="http://www.w3schools.com/furniture">
        <h:table>
          <h:tr>
            <h:td>Apples</h:td>
            <h:td>Bananas</h:td>
          </h:tr>
        </h:table>
        <f:table>
          <f:name>African Coffee Table</f:name>
          <f:width>80</f:width>
          <f:length>120</f:length>
        </f:table>
      </root>
    }

    @mapper.mappings = {
      :html_table_rows => ["/root/h:table/h:tr/h:td", { :text => "." }],
      :an_actual_table => {
        :name   => "/root/f:table/f:name",
        :width  => "/root/f:table/f:width",
        :length => "/root/f:table/f:length"
      }
    }

    @mapper.namespaces = {
      "h" => "http://www.w3.org/TR/html4/",
      "f" => "http://www.w3schools.com/furniture"
    }

    data = @mapper.map(xml)

    data[:html_table_rows].size.should == 2
    data[:html_table_rows][0][:text].should  == "Apples"

    data[:an_actual_table][:name].should  == "African Coffee Table"
    data[:an_actual_table][:width].should == "80"
  end

end
