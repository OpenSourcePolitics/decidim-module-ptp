# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module CompleteVotingPopup
      extend ActiveSupport::Concern

      included do
        before_action :completed_vote_snippets
      end

      private

      def completed_vote_snippets
        return if request.xhr?
        return unless respond_to?(:snippets)
        return unless session.delete(:booth_vote_completed)

        component_id = session.delete(:booth_voted_component)
        return unless component_id

        component = Decidim::Component.find(component_id)
        snippets.add(:head, <<~HTML
          <script type="text/template" id="vote-completed-snippet">
            #{cell("decidim/budgets_booth/vote_completed", component)}
          </script>
        HTML
        )
        snippets.add(:head, add_javascript_file)
      end

      def add_javascript_file
        if Rails.env.test?
          if File.exist?(Rails.root.join("public", "packs-test", "js", "decidim_handle_voting_complete.js"))
            <<~HTML
              <script src="/packs-test/js/decidim_handle_voting_complete.js" defer="defer"></script>
            HTML
          else
            <<~HTML
              <script src="/decidim-packs/js/decidim_handle_voting_complete.js" defer="defer"></script>
            HTML
          end
        else
          <<~HTML
            <script src="/decidim-packs/js/decidim_handle_voting_complete.js" defer="defer"></script/>
          HTML
        end
      end
    end
  end
end
