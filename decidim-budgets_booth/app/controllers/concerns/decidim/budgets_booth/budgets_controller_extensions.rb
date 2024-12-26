# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::VotingSupport

      included do
        layout :determine_layout

        private

        def determine_layout
          "layouts/decidim/application"
        end
      end
    end
  end
end
