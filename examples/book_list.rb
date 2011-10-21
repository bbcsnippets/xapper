require "xapper"
require "pp"

xml = %q{
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
}

puts "Mapping: \n #{xml}"

mapper = Xapper::Mapper.new

mapper.mappings = {
  :type   => "/response/@type",
  :title  => "/response/title",
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

puts "\nTo:\n\n"

pp mapper.map(xml)
