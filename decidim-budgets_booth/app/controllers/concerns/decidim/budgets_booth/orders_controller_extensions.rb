# frozen_string_literal: true

# Customizes the line items controller
module Decidim
  module BudgetsBooth
    module OrdersControllerExtensions
      include ::Decidim::BudgetsBooth::VotingSupport
      extend ActiveSupport::Concern

      included do
        helper_method :budget

        def checkout
          enforce_permission_to :vote, :project, order: current_order, budget: budget, workflow: current_workflow
          Decidim::Budgets::Checkout.call(current_order) do
            on(:ok) do
              reset_workflow
              handle_user_redirect
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
              redirect_to decidim_budgets.budgets_path
            end
          end
        end

        def show
          raise ActionController::RoutingError, "Not Found" unless order

          respond_to do |format|
            format.html { redirect_to decidim_budgets.budgets_path }
            format.js { render }
          end
        end

        private

        def handle_user_redirect
          if voted_all_budgets?
            session[:booth_vote_completed] = true
            session[:booth_voted_component] = current_component.id
            redirect_to success_redirect_path
          else
            session[:booth_thanks_message] = true
            redirect_to decidim_budgets.budgets_path
          end
        end

        def reset_workflow
          @current_workflow = Decidim::Budgets.workflows[workflow_name].new(current_component, current_user)
        end

        def order
          return unless current_order.present? && current_order.checked_out_at.present?

          current_order
        end
      end
    end
  end
end
