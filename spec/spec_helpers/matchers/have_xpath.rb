Spec::Matchers.define :have_xpath do |xpath_string|
  match do |xml|
    xml.xpath(xpath_string).empty?.should be_false
  end

  failure_message_for_should do |xml|
    "expected the following XML document to have XPath #{xpath_string}\n #{xml}"
  end

  failure_message_for_should_not do |actual|
    "expected the following XML document not to have XPath #{xpath_string}\n #{xml}"
  end
end
