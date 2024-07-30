# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class OrderCreatedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent

      def notification_title
        I18n.t(
          'decidim.budgets_booth.order_created_event.notification_title',
        order_id: resource.id
        )
      end

      def notification_body
        I18n.t('decidim.budgets_booth.order_created_event.notification_body',
               user_name: resource.user.name,
               budget_name: resource.budget.title
        )
      end

      private

      def resource_title
        resource.budget.title
      end

      def resource_path
        Decidim::Engine.routes.url_helpers.budget_path(resource.budget)
      end
    end
  end
end
