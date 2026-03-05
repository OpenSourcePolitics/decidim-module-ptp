# frozen_string_literal: true

shared_context "with scopes" do
  let(:parent_scope) { create(:scope, organization:) }
  let!(:subscopes) { create_list(:scope, 3, parent: parent_scope, organization:) }
end

shared_context "with scoped budgets" do
  include_context "with scopes"

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, settings: component_settings, organization:) }
  let(:component_settings) { { scopes_enabled: true, scope_id: parent_scope.id } }

  let(:budgets) { create_list(:budget, 3, component:, total_budget: 100_000) }
  let!(:first_projects_set) { create_list(:project, projects_count, budget: budgets[0], budget_amount: 25_000) }
  let!(:second_projects_set) { create_list(:project, projects_count, budget: budgets[1], budget_amount: 25_000) }
  let!(:last_projects_set) { create_list(:project, projects_count, budget: budgets[2], budget_amount: 25_000) }

  before do
    # We update the description to be less than the truncation limit. To test the truncation, we update those in tests.
    budgets[0].update!(scope: parent_scope, description: { en: "<p>Eius officiis expedita. 55</p>" })
    budgets[1].update!(scope: subscopes[0], description: { en: "<p>Eius officiis expedita. 56</p>" })
    budgets[2].update!(scope: subscopes[1])
  end
end

shared_context "with single scoped budget" do
  include_context "with scopes"

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, settings: component_settings, organization:) }
  let(:component_settings) { { scopes_enabled: true, scope_id: parent_scope.id } }

  let!(:budget) { create(:budget, component:, total_budget: 100_000) }
  let!(:projects_set) { create_list(:project, 3, budget:, budget_amount: 25_000) }

  before do
    budget.update!(scope: subscopes[0], description: { en: "<p>Eius officiis expedita. 55</p>" })
  end
end

shared_context "with a survey" do
  let!(:participatory_space) { component.participatory_space }
  let!(:surveys_component) { create(:surveys_component, :published, participatory_space:) }
  let!(:survey) { create(:survey, component: surveys_component) }
  let!(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
end
