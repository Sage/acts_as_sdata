Factory.define :pagination_params, :class => SData::Collection::PaginationParams do |pagination_params|
  pagination_params.feed_options :default_items_per_page => 10, :maximum_items_per_page => 100
  pagination_params.params Hash.new
end
