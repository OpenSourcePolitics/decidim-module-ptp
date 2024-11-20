# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectsControllerExtensions
      extend ActiveSupport::Concern
      include VotingSupport

      included do
        before_action :set_view_mode, only: :index # added
        layout :determine_layout # added

        def index
          raise ActionController::RoutingError, "Not Found" unless budget

          #raise ActionController::RoutingError, "Not Found" unless allow_access?
        end

        def show
          raise ActionController::RoutingError, "Not Found" unless budget
          raise ActionController::RoutingError, "Not Found" unless project
          #raise ActionController::RoutingError, "Not Found" unless allow_access?
        end
      end

      private

      #def allow_access?
      #  return false if voting_booth_forced? && voting_enabled? && !voted_this?(budget)
      #
      #  true
      #end
      #added
      def determine_layout
        "decidim/budgets/voting_layout"
      end

      def set_view_mode
        @view_mode ||= params[:view_mode] || session[:view_mode] || default_view_mode
        session[:view_mode] = @view_mode
      end

      def default_view_mode
        #@default_view_mode ||= current_component.settings.attachments_allowed? ? "grid" : "list"
        @default_view_mode = "grid"
      end
    end
  end
end
