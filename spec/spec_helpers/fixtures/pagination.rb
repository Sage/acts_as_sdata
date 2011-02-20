Factory.define :pagination, :class => SData::Collection::Pagination do |pagination|
  pagination.pagination_params { Factory.build :pagination_params }
  pagination.entry_count 22
end
