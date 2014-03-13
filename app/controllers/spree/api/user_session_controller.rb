module Spree
  module Api
    class UserSessionController < Spree::Api::BaseController
      include Spree::Core::ControllerHelpers::Auth
      include Spree::Core::ControllerHelpers::Order

      def check_for_user_or_api_key
        # User is already authenticated with Spree, make request this way instead.
        # return true if @current_api_user = try_spree_current_user || !Spree::Api::Config[:requires_authentication]

        # if api_key.blank? && order_token.blank?
        #   render "spree/api/errors/must_specify_api_key", :status => 401 and return
        # end
      end
      def authenticate_user
        unless @current_api_user
        #binding.pry
          if params[:session][:login].blank? && (requires_authentication? || api_key.present?)
            render "spree/api/errors/unauthorized", :status => 401 and return
          else
            # An anonymous user
            @current_api_user = Spree::User.find_for_database_authentication(:login => params[:session][:login])
          end
        end
      end

      def create
        # if user.present?
        #   @order = current_order
        #   @user = user
        #   return respond_with(@user, :status => 200, :default_template => :show)
        # end
        #binding.pry
        #user = Spree::User.find_for_database_authentication(:login => params[:session][:login])
        if user && user.valid_password?(params[:session][:password])&& !user.seller.suspend?
          @user = user
          return respond_with(@user, :status => 200, :default_template => :show)
        else
          render "spree/api/errors/not_found", :status => 404 and return
        end
      end

      def show
        # lookup user by token or session
        #binding.pry
        if user && !user.seller.suspend?
          @order = current_order
          @user = user
          respond_with(@user, :status => 200, :default_template => :show)
        else
          render "spree/api/errors/not_found", :status => 404 and return
        end
      end

      def destroy
        # Do we really need to clear cookies & session?
        # Not all api clients will be browsers.
        cookies.clear
        session.clear
        super
      end

      private

      def user
        @current_api_user || try_spree_current_user
      end
    end
  end
end
