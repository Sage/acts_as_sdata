Factory.define :healthy_entry, :parent => :customer do
  
end

Factory.define :entry_with_erroneous_payload, :parent => :customer do |entry|
  entry.after_build do |entry|
    entry.stub!(:resource_header_attributes).and_raise("Something went wrong")
  end
end

Factory.define :completely_erroneous_entry, :parent => :customer do |entry|
  entry.after_build do |entry|
    entry.stub!(:id).and_raise("Something went wrong")
  end
end
