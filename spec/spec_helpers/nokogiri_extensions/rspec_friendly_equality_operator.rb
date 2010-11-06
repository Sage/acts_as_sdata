class Nokogiri::XML::NodeSet
  def ==(other)
    if other.is_a?(String)
      self.to_s == other
    else
      super(other)
    end
  end
end
