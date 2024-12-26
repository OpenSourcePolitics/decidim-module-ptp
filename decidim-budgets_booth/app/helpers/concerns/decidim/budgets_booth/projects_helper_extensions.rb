# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the projects helper
    module ProjectsHelperExtensions
      include VotingSupport

      delegate :progress?, :budgets, to: :current_workflow

      def thanks_popup?
        session[:booth_thanks_message] == true
      end

      def handle_thanks_popup
        remove_thanks_session if thanks_popup?
      end

      def remove_thanks_session
        session.delete(:booth_thanks_message)
      end

      def thanks_text
        translated_attribute(component_settings.try(:thanks_text)).presence || t("decidim.budgets.voting.thanks_message_modal.default_text")
      end

      def i18n_scope
        "decidim.budgets.projects.pre_voting_budget_summary.pre_vote"
      end

      def budgets_count
        Decidim::Budgets::Budget.where(component: current_component).count
      end

      def voting_booth_forced?
        current_workflow.try(:voting_booth_forced?)
      end

      def toggle_view_mode_link(current_mode, target_mode, title, params)
        path = budget_projects_path(params.permit(:order, filter: {}).merge({ view_mode: target_mode }))
        icon_name = target_mode == "grid" ? "layout-grid-fill" : "list-check"
        icon_class = "view-icon--disabled" unless current_mode == target_mode

        link_to path, remote: true, title: title do
          icon(icon_name, class: icon_class, role: "img", "aria-hidden": true)
        end
      end

      def projects_container_class(view_mode)
        view_mode == "grid" ? "card__grid-grid" : "card__list-list"
      end

      def card_size_for_view_mode(view_mode)
        view_mode == "grid" ? :g : :l
      end

      def budget_title
        decidim_escape_translated(budget.title).html_safe
      end
    end
  end
end
