Factory.define :pagination, :class => SData::Collection::Pagination do |pagination|
  pagination.default_items_per_page 10
  pagination.maximum_items_per_page 100
  pagination.start_index 1
  pagination.count 100
end
