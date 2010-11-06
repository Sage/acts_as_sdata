Spec::Matchers.define :have_xpath do |xpath_string|
  match do |xml|
    xml.xpath(xpath_string).should_not be_empty
  end
end
