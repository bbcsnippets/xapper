# XML to ruby hash mapper

A simple mapper that takes a mapping and converts your ugly-XML to a lovely-ruby hash.

## Install


Use [Bundler](http://gembundler.com/) + git, add this to your `Gemfile`

    gem "xml-to-ruby-hash-mapper", :git => "http://github.com/bbcsnippets/xml-to-ruby-hash-mapper"

In your code

    require "xml_to_ruby_hash_mapper"

## Usage

### Setup

Get a mapper object

    mapper = XmlToRubyHashMapper::XmlMapper::Mapper.new

And some hopefully less contrived XML

    <response type="book_list">
      <title>A list of books on my shelf</title>
      <books>
        <book author="Boris Akunin">
          <title>The Winter Queen</title>
        </book>
        <book author="Neil Gaiman">
          <title>Neverwhere</title>
        </book>
        <book author="Hermann Hesse">
          <title>Steppenwolf</title>
        </book>
      </books>
    </response>

### Mapping text values and attributes using xpath

    mapper.mappings = {
      :type   => "/response/@type",
      :title  => "/response/title"
    }

    data = mapper.map(xml)

    data[:type]  #=> "book_list"
    data[:title] #=> "A list of books on my shelf"

### Mapping lists of XML nodes into arrays of hashes

    mapper.mappings = {
      :books => ["/response/books/book", {
        :title  => "title",
        :author => "@author"
      }]
    }

    data = mapper.map(xml)

    data[:books].size        #=> 3
    data[:books][0][:title]  #=> "The Winter Queen"
    data[:books][0][:author] #=> "Boris Akunin"


### Using a lambda to convert values

You can map via a lambda, the current [Nokogiri](http://nokogiri.org/) node is passed as an argument

    mapper.mappings = {
      :books => ["/response/books/book", {
        :title  => "title",
        :author => {
          :name => "@author",
          :wiki => lambda do |node|
            "http://en.wikipedia.org/wiki/" + node.attribute('author').value.gsub(" ", "_")
          end
        }
      }]
    }

    data = mapper.map(xml)
    data[:books][0][:author][:wiki] #=> "http://en.wikipedia.org/wiki/Boris_Akunin"

### Using namespaces

You can map XML namespaces, the mapper just needs to know about them first

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

    mapper.mappings = {
      :html_table_rows => ["/root/h:table/h:tr/h:td", { :text => "." }],
      :an_actual_table => {
        :name   => "/root/f:table/f:name",
        :width  => "/root/f:table/f:width",
        :length => "/root/f:table/f:length"
      }
    }

    mapper.namespaces = {
      "h" => "http://www.w3.org/TR/html4/",
      "f" => "http://www.w3schools.com/furniture"
    }

    data = mapper.map(xml)

    data[:html_table_rows].size      # => 2
    data[:html_table_rows][0][:text] # => "Apples"

    data[:an_actual_table][:name]    # => "African Coffee Table"
    data[:an_actual_table][:width]   # => "80"

## Examples

See `examples/*.rb`, run with `rake examples`

## Development

Please send new code in the form of a pull requests with tests. Run the current test suite with ...

    rake spec         # Runs spec/*_spec.rb

## Contributors:

* [Matt Haynes](https://github.com/matth)
* [Anuj Dutta](https://github.com/andhapp/)
* [Jim Lynn](https://github.com/JimLynn)
