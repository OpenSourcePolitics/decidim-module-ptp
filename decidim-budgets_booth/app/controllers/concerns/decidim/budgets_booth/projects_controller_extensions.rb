# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectsControllerExtensions
      extend ActiveSupport::Concern
      include VotingSupport

      included do
        before_action :set_view_mode, only: :index
        layout :determine_layout

        def index
          raise ActionController::RoutingError, "Not Found" unless budget
        end

        def show
          raise ActionController::RoutingError, "Not Found" unless budget
          raise ActionController::RoutingError, "Not Found" unless project
        end
      end

      private

      def determine_layout
        "decidim/budgets/voting_layout"
      end

      def set_view_mode
        @view_mode ||= params[:view_mode] || session[:view_mode] || default_view_mode
        session[:view_mode] = @view_mode
      end

      def default_view_mode
        @default_view_mode = "grid"
      end
    end
  end
end
