rspec_friendly_equality_operator = lambda do
  def ==(other)
    if other.is_a?(String)
      self.to_s == other
    else
      super(other)
    end
  end
end

[Nokogiri::XML::NodeSet, Nokogiri::XML::Text, Nokogiri::XML::Attr].each do |klass|
  klass.class_eval &rspec_friendly_equality_operator
end
