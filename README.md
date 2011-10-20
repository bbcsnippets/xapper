# XML to ruby hash mapper

A simple mapper that takes a mapping and converts your ugly-XML to a lovely-ruby hash.

## Install


Use [Bundler](http://gembundler.com/) + git, add this to your `Gemfile`

    gem "xml-to-ruby-hash-mapper", :git => "http://github.com/bbcsnippets/xml-to-ruby-hash-mapper"

In your code

    require "xml_to_ruby_hash_mapper"

## Usage

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

You can map simple attributes and text values using xpath

    mapper.mappings = {
      :type   => "/response/@type",
      :title  => "/response/title"
    }

    data = mapper.map(xml)

    data[:type]  #=> "book_list"
    data[:title] #=> "A list of books on my shelf"

You can map lists into arrays

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


## Development

Please send new code in the form of a pull requests with tests. Run the current test suite with ...

    rake spec         # Runs spec/*_spec.rb

## Contributors:

[Matt Haynes](https://github.com/matth)
[Anuj Dutta](https://github.com/andhapp/)
[Jim Lynn](https://github.com/JimLynn)
