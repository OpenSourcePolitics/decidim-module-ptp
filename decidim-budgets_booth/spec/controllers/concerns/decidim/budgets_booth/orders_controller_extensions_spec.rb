# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::OrdersControllerExtensions, type: :controller do
  controller(Decidim::Budgets::OrdersController) do
    include Decidim::BudgetsBooth::OrdersControllerExtensions
  end

  routes { Decidim::Budgets::Engine.routes }

  let(:user) { create(:user, :confirmed, organization:) }
  let(:component) { create(:budgets_component, organization:) }
  let(:projects_count) { 5 }

  describe "when there are multiple budgets" do
    include_context "with scoped budgets"

    let!(:budgets) { create_list(:budget, 3, component:, total_budget: 100_000_000) }
    let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
    let(:projects) { create_list(:project, 3, budget: budgets.first, budget_amount: 75_000_000) }
    let!(:order) { create(:order, user:, budget: budgets.first) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_user"] = user
      request.env["decidim.current_participatory_space"] = component.participatory_space
      request.env["decidim.current_component"] = component
      order.projects << projects.first
      order.save!
      allow(controller).to receive_messages(budget: budgets.first, current_user: user)
    end

    describe "#checkout" do
      context "when command call returns ok" do
        before do
          component.update!(settings: { workflow: "all" })
        end

        context "and there are several budgets" do
          it "sets thanks session and redirects the user to budgets_path" do
            post :checkout, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
            expect(session[:booth_thanks_message]).to be(true)
            expect(response).to redirect_to(decidim_budgets.budgets_path)
          end

          it "enqueues job" do
            expect do
              post :checkout, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
            end.to have_enqueued_job(Decidim::EventPublisherJob)
          end
        end
      end

      context "when invalid" do
        before do
          # make order invalid
          projects.first.update!(budget_amount: 25_000_000)
        end

        it "redirects the user with flash message" do
          post :checkout, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
          expect(response).to redirect_to(decidim_budgets.budgets_path)
          expect(flash[:alert]).to have_content("There was a problem processing your vote")
        end
      end
    end

    describe "#show" do
      context "when order does not exist" do
        it "renders error" do
          expect do
            get :show, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "when order exists" do
        before do
          order.update!(checked_out_at: Time.current)
        end

        it "redirects the html requests" do
          get :show, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
          expect(response).to redirect_to(decidim_budgets.budgets_path)
        end
      end
    end
  end

  describe "when there is one budget" do
    include_context "with single scoped budget"

    describe "#checkout" do
      context "and there is one budget" do
        let(:decidim_participatory_processes) { Decidim::EngineRouter.main_proxy(component.participatory_space) }
        let!(:order) { create(:order, user:, budget:) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_user"] = user
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          projects_set.first.update!(budget_amount: 70_000)
          order.projects << projects_set.first
          order.save!
          allow(controller).to receive_messages(budget:, current_user: user)
        end

        it "enqueues job" do
          expect do
            post :checkout, params: { budget_id: budget.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
          end.to have_enqueued_job(Decidim::EventPublisherJob)
        end

        context "and vote_success_url is not defined" do
          it "sets thanks session and redirects the user to process_path" do
            post :checkout, params: { budget_id: budget.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
            expect(session[:booth_vote_completed]).to be(true)
            expect(response).to redirect_to(decidim_participatory_processes.participatory_process_path(component.participatory_space))
          end
        end

        context "and vote_success_url is defined" do
          it "sets thanks session and redirects the user to vote_success_url" do
            component.update!(settings: { vote_success_url: "/processes" })
            post :checkout, params: { budget_id: budget.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
            expect(session[:booth_vote_completed]).to be(true)
            expect(response).to redirect_to(decidim_participatory_processes.participatory_processes_path)
          end
        end
      end
    end
  end
end
