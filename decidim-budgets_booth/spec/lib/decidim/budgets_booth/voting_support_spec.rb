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
      step_settings: step_settings,
      organization: organization
    )
  end
  let(:step_settings) { { active_step_id => { votes: votes } } }
  let(:votes) { "enabled" }
  let(:active_step_id) { component.participatory_space.active_step.id }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:projects_count) { 5 }
  let(:projects) { create_list(:project, 3, budget: budgets.first, budget_amount: 75_000) }
  let(:second_projects) { create_list(:project, 3, budget: budgets.second, budget_amount: 75_000) }
  let(:third_projects) { create_list(:project, 3, budget: budgets.third, budget_amount: 75_000) }
  let!(:order) { create(:order, user: user, budget: budgets.first) }
  let!(:second_order) { create(:order, user: user, budget: budgets.second) }
  let!(:third_order) { create(:order, user: user, budget: budgets.third) }

  include_context "with scoped budgets"

  before do
    component.update!(settings: component_settings.merge(workflow: "all"))
    allow(dummy).to receive_messages(component: component, user: user, organization: organization, current_settings: component.current_settings)
  end

  describe "#voting_enabled?" do
    it "is enabled by default" do
      expect(subject).to be_voting_enabled
    end
  end

  describe "#voted_any?" do
    context "when user exist but not voted" do
      it "returns false" do
        expect(subject).not_to be_voted_any
      end
    end

    context "when voted" do
      before do
        vote_this(order, projects.first)
      end

      it "returns true" do
        expect(subject.voted_any?).to be(true)
      end
    end
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

  describe "#hide_unvoted?" do
    context "when maximum_budgets_to_vote_on is not set" do
      before do
        vote_this(order, projects.first)
      end

      it "does not hide any budgets" do
        expect(subject.hide_unvoted?(budgets.first)).to be(false)
        expect(subject.hide_unvoted?(budgets.second)).to be(false)
      end
    end

    context "when maximum_budgets_to_vote_on is set" do
      before do
        component.update(settings: component_settings.merge(maximum_budgets_to_vote_on: 1))
        vote_this(order, projects.first)
      end

      it "does not hide voted budgets" do
        expect(subject.hide_unvoted?(budgets.first)).to be(false)
      end

      it "hides unvoted budgets" do
        expect(subject.hide_unvoted?(budgets.second)).to be(true)
      end
    end

    context "when voting is not open" do
      let(:votes) { "disabled" }

      before do
        component.update!(settings: component_settings.merge(maximum_budgets_to_vote_on: 1), step_settings: step_settings)
        vote_this(order, projects.first)

        allow(dummy).to receive(:current_settings).and_return(component.current_settings)
      end

      it "does not hide unvoted budgets, even when the maximum is reached" do
        expect(subject.hide_unvoted?(budgets.first)).to be(false)
        expect(subject.hide_unvoted?(budgets.second)).to be(false)
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
