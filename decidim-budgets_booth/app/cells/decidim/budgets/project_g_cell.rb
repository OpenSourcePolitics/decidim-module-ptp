# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Budgets
    # This cell renders the Grid (:g) project card
    # for an instance of a Project
    class ProjectGCell < Decidim::CardGCell
      include Decidim::Budgets::ProjectsHelper
      include Decidim::Proposals::ApplicationHelper
      include Decidim::LayoutHelper

      alias project model

      delegate :state_item, to: :metadata_cell_instance

      def show
        render
      end

      def title
        decidim_escape_translated(model.title).html_safe
      end

      def metadata_cell = "decidim/budgets/project_metadata"

      def metadata_cell_instance
        @metadata_cell_instance ||= cell("decidim/budgets/project_metadata", model)
      end

      def resource_image_path
        project.photos.first&.url if project.attachments.present?
      end

      private

      def resource_path
        resource_locator([project.budget, project]).path
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def current_order
        @current_order ||= controller.try(:current_order)
      end

      def show_only_added
        options[:show_only_added]
      end

      def view_mode
        options[:view_mode]
      end

      def classes
        super.merge(metadata: "card__list-metadata")
      end

      def resource_id = "project-#{project.id}-item"
    end
  end
end
