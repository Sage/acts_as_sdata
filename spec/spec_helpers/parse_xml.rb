def parse_xml(xml)
  options = Nokogiri::XML::ParseOptions::DEFAULT_XML | Nokogiri::XML::ParseOptions::NOBLANKS
  Nokogiri::XML(xml, nil, nil, options)
end
