module SData
  module Application
    module Logging
      def logger
        @logger ||= returning Logger.new(options.log_file) do |logger|
          logger.level = options.log_level
        end
      end
    end
  end
end
