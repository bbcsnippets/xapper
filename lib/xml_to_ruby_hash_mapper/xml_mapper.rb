module XmlToRubyHashMapper
  module XmlMapper

    @@mappings = {}

    def mappings(hash, namespaces = nil)
      mapper = Mapper.new
      mapper.mappings = hash[hash.keys[0]]
      mapper.namespaces = namespaces
      @@mappings[hash.keys[0]] = mapper
    end

    def map(mapping, xml)
      @@mappings[mapping].map(xml)
    end

    class Mapper

      attr_accessor :mappings
      attr_accessor :namespaces

      def map(xml_str)
        xml  = Nokogiri::XML(xml_str)
        map_xml_data(xml, @mappings, {})
      end

      protected

      def map_xml_data(xml, mappings, data)

        mappings.each_pair do |key, val|

          # We have a proc object
          if val.is_a? Proc
            data[key] = val.call xml
            next
          end

          # Recurse on hash
          if val.is_a? Hash
            data[key] = map_xml_data(xml, val, {})
            next
          end

          if val.is_a? Array
            xpath = val[0]
            submap = val[1]
            items = xml.xpath(xpath, @namespaces)
            data[key] = items.map {|node| map_xml_data(node, submap, {})}
            next
          end

          # We have an xpath to lookup
          node      = xml.xpath(val,@namespaces)[0]

          if node.class == Nokogiri::XML::Element
            data[key] = node.content
          elsif node.class == Nokogiri::XML::Attr
            data[key] = node.value
          else
            data[key] = nil
          end

        end

        data

      end

    end

  end
end
