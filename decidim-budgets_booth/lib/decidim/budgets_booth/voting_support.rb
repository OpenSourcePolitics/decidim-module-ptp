# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module VotingSupport
      delegate :budgets, :voted, :voted?, to: :current_workflow

      def voting_booth_forced?
        current_workflow.try(:voting_booth_forced?)
      end

      def decidim_budgets
        @decidim_budgets ||= Decidim::EngineRouter.main_proxy(current_component)
      end

      def status(budget)
        @status ||= current_workflow.status(budget)
      end

      # maximum_budgets_to_vote_on is being set by the admin. the default is zero, which means users can
      # vote in all available budgets. To check that user has voted to all available budgets, we should
      # consider this settings as well. If budget component workflow is random or one, available budgets
      # will be equal to 1
      def voted_all_budgets?
        default_limit = current_component.settings.maximum_budgets_to_vote_on || 0
        available_budgets = %w(random one).include?(current_component.settings.workflow) ? 1 : budgets.count
        vote_limit = if default_limit.zero?
                       available_budgets
                     else
                       [default_limit, available_budgets].min
                     end

        voted.count >= vote_limit
      end

      # This configuration option can be set in component settings, the default url when the user has voted on all budgets
      # is budgets path
      def success_redirect_path
        if budgets.count == 1 && component_settings.try(:vote_success_url).blank?
          decidim_participatory_processes.participatory_process_path(current_component.participatory_space)
        else
          component_settings.try(:vote_success_url).presence || decidim_budgets.budgets_path
        end
      end

      # This configuration option can be set in component settings, the default url when the user cancels voting is the root path.
      def cancel_redirect_path
        component_settings.try(:vote_cancel_url).presence || decidim.root_path
      end
    end
  end
end
