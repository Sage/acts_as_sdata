def setup_active_record
  ActiveRecord::Base.establish_connection :adapter => "sqlite3",
    :database  => ":memory:"
end

require 'atom'
require 'dirge'
require 'active_record'
require 'cgi'

setup_active_record

$:.unshift ~'../lib'

require ~'../init'

require 'nokogiri'
require 'factory_girl'

require ~'spec_helpers/fixtures/customer'
require ~'spec_helpers/fixtures/entry'
require ~'spec_helpers/fixtures/pagination_params'

require ~'spec_helpers/parse_xml'
require ~'spec_helpers/nokogiri_extensions/xxx_with_ns'
require ~'spec_helpers/nokogiri_extensions/rspec_friendly_equality_operator'
require ~'spec_helpers/remove_constants'

require ~'spec_helpers/raised_exception'
require ~'spec_helpers/matchers/have_xpath'

require ~'spec_helpers/stubs/model_base'
require ~'spec_helpers/stubs/user'
require ~'spec_helpers/stubs/customer'
require ~'spec_helpers/stubs/contact'
require ~'spec_helpers/stubs/address'
require ~'spec_helpers/stubs/sd_uuid'
require ~'spec_helpers/stubs/sdata_application'

SData.reset!
SData.config = {:base_url => 'http://www.example.com', 
                               :application => 'example', 
                               :contract_namespace => 'SData::Contracts',
                               :contracts => ['myContract'],
                               :defaultContract => ['myContract'],
                               :schemas => {
                                 "xs"         => "http://www.w3.org/2001/XMLSchema",
                                 "cf"         => "http://www.microsoft.com/schemas/rss/core/2005",
                                 "sme"        => "http://schemas.sage.com/sdata/sme/2007",
                                 "sc"         => "http://schemas.sage.com/sc/2009",
                                 "crmErp"     => "http://schemas.sage.com/crmErp/2008",
                                 "http"       => "http://schemas.sage.com/sdata/http/2008/1",
                                 "sync"       => "http://schemas.sage.com/sdata/sync/2008/1",
                                 "opensearch" => "http://a9.com/-/spec/opensearch/1.1/",
                                 "sdata"      => "http://schemas.sage.com/sdata/2008/1",
                                 "xsi"        => "http://www.w3.org/2001/XMLSchema-instance",
                                 "sle"        => "http://www.microsoft.com/schemas/rss/core/2005",
                                 "bb"         => "http://www.billingboss.com/schemas/sdata"
                               },
                               :show_stack_trace => true}
