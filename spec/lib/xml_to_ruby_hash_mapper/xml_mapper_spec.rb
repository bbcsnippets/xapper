require 'spec_helper'

describe XmlToRubyHashMapper::XmlMapper::Mapper do

  before do
    @mapper = XmlToRubyHashMapper::XmlMapper::Mapper.new
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

end
