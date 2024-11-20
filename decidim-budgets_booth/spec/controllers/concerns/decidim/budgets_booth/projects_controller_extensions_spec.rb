# frozen_string_literal: true

require "spec_helper"

module Decidim
  module BudgetsBooth
    describe ProjectsControllerExtensions, type: :controller do
      routes { Decidim::Budgets::Engine.routes }

      controller(::Decidim::Budgets::ProjectsController) do
        include ProjectsControllerExtensions
      end

      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:component) do
        create(
          :budgets_component,
          step_settings: step_settings,
          participatory_space: participatory_space,
          organization: organization
        )
      end
      let(:parent_scope) { create(:scope, organization: organization) }
      let(:step_settings) { { active_step_id => { votes: votes } } }
      let(:active_step_id) { participatory_space.active_step.id }
      let!(:budgets) { create_list(:budget, 3, component: component) }
      let(:project) { create(:project, budget: budgets.last) }
      let(:votes) { "enabled" }
      let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "#index" do
        context "when budget" do
          it "renders index" do
            get :index, params: { budget_id: budgets.last.id }
            expect(response).to render_template(:index)
          end
        end

        context "when no budget" do
          it "raises error" do
            expect do
              get :index, params: { budget_id: nil }
            end.to raise_error(ActionController::RoutingError, "Not Found")
          end
        end
      end

      describe "#show" do
        context "when budget and project" do
          it "renders show" do
            get :show, params: { id: project.id, budget_id: budgets.last.id }
            expect(response).to render_template(:show)
          end
        end

        context "when budget and no project" do
          it "raises error" do
            expect do
              get :show, params: { id: 1000000, budget_id: budgets.last.id }
            end.to raise_error(ActionController::RoutingError, "Not Found")
          end
        end

        context "when no budget and project" do
          it "raises error" do
            expect do
              get :show, params: { id: project.id, budget_id: nil }
            end.to raise_error(ActionController::RoutingError, "Not Found")
          end
        end
      end
    end
  end
end
