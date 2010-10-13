__DIR__ = File.dirname(__FILE__)
require File.join(__DIR__, 'auth', 'authentication')
require File.join(__DIR__, 'auth', 'authorization')

module SData
  module Application
    module Auth
      attr_accessor :current_user, :target_user
      
      include Authentication
      include Authorization

      def logged_in?
        !! current_user
      end

      def auth!
        authenticate!
        authorize!
      end
    end
  end
end
