RSpecFriendlyEqualityOperator = Trait.new do
  def ==(other)
    if other.is_a?(String)
      self.to_s == other
    else
      super(other)
    end
  end
end

[Nokogiri::XML::NodeSet, Nokogiri::XML::Text, Nokogiri::XML::Attr].each do |klass|
  klass.__send__ :include, RSpecFriendlyEqualityOperator
end
