module SData
  module Resource
    module Uuid
      def has_sdata_uuid
        self.__send__ :include, InstanceMethods
      end

      module InstanceMethods
        def uuid
          record = sd_uuid
          record ? record.uuid : nil
        end

        # WARN: don't cache this, it will potentially break things
        # RADAR: This finds the most recently updated of potentially many sd_uuids -- see
        # http://interop.sage.com/daisy/sdataSync/Link/525-DSY.html, linking scenario 3
        def sd_uuid
          result = SData::SdUuid.find_for_virtual_instance(self)
          if result.nil? && (uuid = self.sdata_uuid_for_record)
            if !SData::SdUuid.find_uuid_record_for_virtual_model_owner_and_uuid(self.class, self.owner, uuid)
              result = create_or_update_uuid!(uuid)
            else
              SData::SdUuid.reassign_uuid!(uuid, self.class, self.owner, self.baze.id)
              result = self
            end
          end
          result
        end

        def create_or_update_uuid!(value)
          SData::SdUuid.create_or_update_uuid_for(self, value)
        end

        def linked?
          !sd_uuid.nil?
        end
      end
    end
  end
end
