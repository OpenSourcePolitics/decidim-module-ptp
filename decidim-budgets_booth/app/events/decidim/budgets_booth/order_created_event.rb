# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class OrderCreatedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent

      def self.model_name
        ActiveModel::Name.new(self, nil, I18n.t('decidim.budgets.voting.voting_notification_event.notification_casted'))
      end

      def notification_title
        I18n.t(
          'decidim.budgets.voting.voting_notification_event.notification_title',
          budget_name: resource_title
          )
      end

      private

      def resource_title
        translated_attribute(resource.budget.title)
      end

      def resource_path
        Decidim::Engine.routes.url_helpers.budget_path(resource.budget)
      end
    end
  end
end
