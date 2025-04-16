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
          line_items = order&.line_items

          @show_help_modal =
            if current_workflow.try(:disable_voting_instructions?)
              false
            elsif rule_enabled
              show_modal(order, minimum_vote, line_items)
            else
              order.blank?
              # case of first click without rule_enabled => we want the modal
            end
        end

        def order
          @order ||= Decidim::Budgets::Order.find_by(user: current_user, budget: budget)
        end

        def show_modal(order, minimum_vote, line_items)
          # when the user first click to add a project, the order is no yet created
          if order.blank?
            #  case of the first click
            # if minimum_vote is 1 => we want the modal
            # if minimum_vote is not 1 => we don't want the modal
            minimum_vote == 1
          elsif line_items && minimum_vote == line_items.size + 1
            # when user clicks to add a project, it has not yet been added in line items so we add + 1 to get the modal at the right time
            # case of second/third... click => we want the modal when minimum_vote == line_items.size + 1
            true
          end
        end
      end
    end
  end
end
