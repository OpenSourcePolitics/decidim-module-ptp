# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::VotingSupport do
  subject { dummy }

  let(:dummy) { klass.new }
  let(:klass) do
    Class.new do
      include Decidim::BudgetsBooth::VotingSupport

      def current_organization
        organization
      end

      def current_user
        user
      end

      def current_participatory_space
        current_component.participatory_space
      end

      def current_component
        component
      end

      def current_workflow
        Decidim::Budgets::Workflows::All.new(current_component, current_user)
      end

      def voting_open?
        current_settings.votes == "enabled"
      end
    end
  end

  let(:component) do
    create(
      :budgets_component,
      settings: component_settings.merge(workflow: "all"),
      step_settings:,
      organization:
    )
  end
  let(:step_settings) { { active_step_id => { votes: } } }
  let(:votes) { "enabled" }
  let(:active_step_id) { component.participatory_space.active_step.id }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:projects_count) { 5 }
  let(:projects) { create_list(:project, 3, budget: budgets.first, budget_amount: 75_000) }
  let(:second_projects) { create_list(:project, 3, budget: budgets.second, budget_amount: 75_000) }
  let(:third_projects) { create_list(:project, 3, budget: budgets.third, budget_amount: 75_000) }
  let!(:order) { create(:order, user:, budget: budgets.first) }
  let!(:second_order) { create(:order, user:, budget: budgets.second) }
  let!(:third_order) { create(:order, user:, budget: budgets.third) }

  include_context "with scoped budgets"

  before do
    component.update!(settings: component_settings.merge(workflow: "all"))
    allow(dummy).to receive_messages(component:, user:, organization:, current_settings: component.current_settings)
  end

  describe "#voted_all_budgets?" do
    context "when maximum_budgets_to_vote_on is not set" do
      context "when not voted all of the budgets" do
        before do
          vote_this(order, projects.first)
        end

        it "returns false" do
          expect(subject.voted_all_budgets?).to be(false)
        end
      end

      context "when voted all of the budgets" do
        before do
          vote_this(order, projects.first)
          vote_this(second_order, second_projects.first)
          vote_this(third_order, third_projects.first)
        end

        it "returns true" do
          expect(subject.voted_all_budgets?).to be(true)
        end
      end
    end

    context "when maximum_budgets_to_vote_on is set" do
      context "when voted the limit" do
        before do
          component.update!(settings: component_settings.merge(maximum_budgets_to_vote_on: 1))
          vote_this(order, projects.first)
        end

        it "returns true" do
          expect(subject.voted_all_budgets?).to be(true)
        end
      end
    end
  end

  describe "#success_redirect_path" do
    context "when vote_succes_url is defined" do
      before do
        component.update!(settings: component_settings.merge(vote_success_url: "http://budget.org"))
        allow(dummy).to receive(:component_settings).and_return(component.settings)
      end

      it "returns vote_success_url" do
        expect(subject.success_redirect_path).to eq(component.settings.vote_success_url)
      end
    end

    context "when vote_succes_url is not defined" do
      before do
        component.update!(settings: component_settings.merge(vote_success_url: nil))
        allow(dummy).to receive(:component_settings).and_return(component.settings)
      end

      it "returns budgets_path" do
        expect(subject.success_redirect_path).to eq(Decidim::EngineRouter.main_proxy(component).budgets_path)
      end
    end
  end

  describe "#cancel_redirect_path" do
    context "when vote_cancel_url is defined" do
      before do
        component.update!(settings: component_settings.merge(vote_cancel_url: "http://budget.org"))
        allow(dummy).to receive(:component_settings).and_return(component.settings)
      end

      it "returns vote_cancel_url" do
        expect(subject.cancel_redirect_path).to eq(component.settings.vote_cancel_url)
      end
    end

    context "when vote_cancel_url is not defined" do
      before do
        component.update!(settings: component_settings.merge(vote_cancel_url: nil))
        allow(dummy).to receive_messages(component_settings: component.settings, decidim: Decidim::EngineRouter.main_proxy(component))
      end

      it "returns budgets_path" do
        expect(subject.cancel_redirect_path).to eq(Decidim::EngineRouter.main_proxy(component).root_path)
      end
    end
  end

  private

  def vote_this(order, project)
    order.projects << project
    order.checked_out_at = Time.current
    order.save!
  end
end
