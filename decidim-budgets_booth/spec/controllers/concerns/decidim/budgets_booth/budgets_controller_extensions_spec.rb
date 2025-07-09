# frozen_string_literal: true

require "spec_helper"

module Decidim
  module BudgetsBooth
    describe BudgetsControllerExtensions, type: :controller do
      controller(::Decidim::Budgets::BudgetsController) do
        include BudgetsControllerExtensions
      end

      describe "#index" do
        routes { Decidim::Budgets::Engine.routes }

        let(:organization) { create(:organization) }
        let(:component) { create(:budgets_component, organization:, settings: component_settings) }
        let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
        let(:component_settings) { { votes: "enabled" } }
        let!(:budgets) do
          [].tap do |list|
            list << create(:budget, component:)
            list << create(:budget, component:)
            list << create(:budget, component:)
          end
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
        end

        context "when voting enabled" do
          it "renders index with budgets_booth application layout" do
            get :index
            expect(response).to render_template(:index, layout: "layouts/decidim/application")
          end
        end

        context "when voting is not enabled" do
          before do
            component.update(settings: component_settings.merge(votes: "finished"))
          end

          it "renders index with budgets_booth voting_layout" do
            get :index
            expect(response).to render_template(:index, layout: "decidim/budgets/voting_layout")
          end
        end
      end
    end
  end
end
