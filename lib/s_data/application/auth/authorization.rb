module SData
  module Application
    module Authorization
      def authorize!
        ensure_subscribed
        ensure_has_access_to_dataset
      end

      # TODO: temporary for Simply testing. Should replace with permit :sdata_user or similar
      # and adjust logic to match for SpSubscriptions.
      def ensure_subscribed
        return if options.environment == :production

        raise Sage::BusinessLogic::Exception::AccessDeniedException, "Not Subscribed" if current_user.unsubscribed?
        raise Sage::BusinessLogic::Exception::ExpiredSubscriptionException, "Subscription Expired" if current_user.expired?
      end

      def ensure_has_access_to_dataset
        raise Sage::BusinessLogic::Exception::AccessDeniedException, "No dataset specified" if params[:dataset].blank?

        # RADAR: will cause link urls to translate from '-' to 'bob' etc, but I think it's better than have
        # inconsistent urls in regular links and endpoint links (endpoints must include sage_username)
        params[:dataset] = current_user.sage_username if params[:dataset] == '-'

        self.target_user = User.find_by_sage_username(params[:dataset])

        raise_access_denied "No access to dataset" unless target_user and dataset_accessible?(params[:dataset])
      end

      def dataset_accessible?(dataset)
        return true if target_user == current_user

        return false if !target_user.biller or !current_user.bookkeeper
        return target_user.biller.bookkeepers.include?(current_user.bookkeeper)
      end

      def raise_access_denied(error_message)
        raise Sage::BusinessLogic::Exception::AccessDeniedException, error_message
      end      
    end
  end
end
