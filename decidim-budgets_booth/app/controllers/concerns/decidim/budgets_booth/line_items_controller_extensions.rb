# frozen_string_literal: true

# Customizes the line items controller
module Decidim
  module BudgetsBooth
    module LineItemsControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :set_help_modal

        helper Decidim::Budgets::VotingHelper

        private

        def set_help_modal
          rule_enabled = current_component[:settings]["global"]["vote_rule_selected_projects_enabled"]
          minimum_vote = current_component[:settings]["global"]["vote_selected_projects_minimum"]
          order ||= Decidim::Budgets::Order.find_by(user: current_user, budget: budget)
          line_items = order&.line_items

          @show_help_modal =
            if current_workflow.try(:disable_voting_instructions?)
              false
            elsif rule_enabled && line_items && minimum_vote == line_items.size + 1
              # when we click to add a project, it has not yet been added in line items so we add + 1 to get the modal at the right time
              true
            else
              order.blank?
            end
        end
      end
    end
  end
end
