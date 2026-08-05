# frozen_string_literal: true

# sax-machine hardcodes `ctx.replace_entities = true` in its Nokogiri handler,
# so a hostile feed can declare an external entity and have us resolve it while
# parsing (XXE): `file://` reads local files and `http://` reaches private
# addresses, both outside the SafeFetch guard that protects the fetch itself.
#
# Turning substitution off only affects entities that point at a SYSTEM
# resource. Predefined (`&amp;`), numeric (`&#233;`) and internally declared
# entities still resolve, so feeds that declare their own HTML entities in a
# DOCTYPE keep working.
module SAXMachine::DisableExternalEntities
  def sax_parse(xml_input)
    parser = Nokogiri::XML::SAX::Parser.new(self)
    parser.parse(xml_input) { |ctx| ctx.replace_entities = false }
  end
end

if SAXMachine.handler == :nokogiri
  SAXMachine::SAXNokogiriHandler.prepend(SAXMachine::DisableExternalEntities)
end
