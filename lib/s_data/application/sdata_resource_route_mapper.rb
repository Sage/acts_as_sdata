# This file not in acts_as_sdata yet cause it is still has BillingBoss-related prefixesin URL. So:
# TODO: extract URL prefixes to options

module SData
  module Application
    module Traits
      ResourceRoutes = Trait.new do
        def self.urlize(string)
          string.gsub("'", "(%27|')").gsub("\s", "(%20|\s)")
        end

        COMMON_PREFIX = "billingboss/:contract/:dataset"

        CONDITION_REGEXP = /([$](linked))/
        PREDICATE_REGEXP = Regexp.new(urlize("[A-z]+\s[A-z]+\s.+")) # Regexp.new(urlize("[A-z]+\s[A-z]+\s'?[^']*'?"))

        # map_sdata_show_instance_with_predicate
        get("/#{COMMON_PREFIX}/:sdata_resource\\(:predicate\\)", :matching => { :predicate => PREDICATE_REGEXP }) do
          auth!
          sdata_show_instance
        end

        # map_sdata_show_instance
        get "/#{COMMON_PREFIX}/:sdata_resource\\(:instance_id\\)" do
          auth!
          sdata_show_instance
        end

        # map_sdata_show_instance_with_condition
        get("/#{COMMON_PREFIX}/:sdata_resource/:condition\\(:instance_id\\)", :matching => { :condition => CONDITION_REGEXP }) do
          auth!
          sdata_show_instance
        end
        
        # map_sdata_create_link
        post("/#{COMMON_PREFIX}/:sdata_resource/:condition", :matching => { :condition => CONDITION_REGEXP }) do
          auth!
          sdata_create_link
        end

        # map_sdata_collection
        get "/#{COMMON_PREFIX}/:sdata_resource" do
          auth!
          sdata_collection
        end

        # map_sdata_collection_with_condition
        get("/#{COMMON_PREFIX}/:sdata_resource/:condition", :matching => { :condition => CONDITION_REGEXP }) do
          auth!
          sdata_collection
        end

        # map_sdata_show_instance_with_condition_and_predicate
        get("/#{COMMON_PREFIX}/:sdata_resource/:condition\\(:predicate\\)", :matching => { :condition => CONDITION_REGEXP, :predicate => PREDICATE_REGEXP }) do
          auth!
          sdata_show_instance
        end

        # map_sdata_create_instance
        post "/#{COMMON_PREFIX}/:sdata_resource" do
          auth!
          sdata_create_instance
        end

        # map_sdata_update_instance
        put "/#{COMMON_PREFIX}/:sdata_resource\\(:instance_id\\)" do
          auth!
          sdata_update_instance
        end

        # map_sdata_sync_source
        post "/#{COMMON_PREFIX}/:sdata_resource/$syncSource" do
          auth!
          sdata_collection_sync_feed
        end

        # map_sdata_sync_source_status
        get "/#{COMMON_PREFIX}/:sdata_resource/$syncSource\\(:trackingID\\)" do
          auth!
          sdata_collection_sync_feed_status
        end

        # map_sdata_sync_source_delete
        delete "/#{COMMON_PREFIX}/:sdata_resource/$syncSource\\(:trackingID\\)" do
          auth!
          sdata_collection_sync_feed_delete
        end

        # map_sdata_receive_sync_results
        post "/#{COMMON_PREFIX}/:sdata_resource/$syncResults\\(:trackingID\\)" do
          auth!
          sdata_collection_sync_results
        end
      end
    end
  end
end
