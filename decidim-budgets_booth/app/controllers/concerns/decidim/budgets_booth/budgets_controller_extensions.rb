# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::VotingSupport

      included do
        layout :determine_layout

        def index
          # if there is an announcement_body, render index
          redirect_to budget_projects_path(current_workflow.single) if current_workflow.single? && announcement_body.nil?
        end

        private

        def determine_layout
          "layouts/decidim/application"
        end
      end
    end
  end
end
