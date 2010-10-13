module SData
  module Application
    module Authentication
      EMAIL_REGEXP = /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/i

      def authenticate!
        login, password = extract_credentials
        user = find_user(login)
        raise_unauthenticated unless CasServer.instance.authenticate?(user.sage_username, password)
        self.current_user = user
      end

      def find_user(login)
        user = login.match(EMAIL_REGEXP) ? User.find_by_email(login) : User.find_by_sage_username(login)
        raise_unauthenticated unless user and user.sage_username
        user
      end
      
      def extract_credentials
        http_auth = Rack::Auth::Basic::Request.new(request.env)
        raise_unauthenticated("No user supplied") unless http_auth.provided? and http_auth.basic? and http_auth.credentials
        http_auth.credentials
      end

      def raise_unauthenticated(error_message="Unauthenticated")
        raise Sage::BusinessLogic::Exception::UnauthenticatedException, error_message
      end
    end
  end
end
