# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe ProjectGCell, type: :cell do
    controller Decidim::Budgets::ProjectsController

    subject(:cell_html) { my_cell.call }


    let(:my_cell) { cell("decidim/budgets/project_g", project, card_size: :g) }
    let!(:organization) { create(:organization) }
    let!(:budgets_component) { create(:budgets_component, organization:) }
    let(:budget) { create(:budget, component: budgets_component) }
    let(:slug) { budgets_component.participatory_space.slug }
    let(:process_id) { budgets_component.participatory_space.id }
    let!(:project) { create(:project, budget:, component: budgets_component) }

    before do
      allow(controller).to receive(:current_component).and_return(budgets_component)
      # avoid rendering project_vote_button that we don't test here
      allow(my_cell).to receive(:cell).and_return("")
    end

    describe "show" do
      it "renders the project item with appropriate id" do
        expect(subject).to have_css("#project-#{project.id}-item")
      end

      it "renders the project title" do
        expect(subject.text).to include(translated_attribute(project.title))
      end

      context "when the project has an image" do
        let!(:attachment) { create(:attachment, attached_to: project) }

        it "renders the project with an image" do
          expect(subject).to have_css("img[src*='city']")
        end
      end

      context "when the project has no image" do
        before { allow(project).to receive(:attachments).and_return([]) }

        it "renders the project without image" do
          expect(subject).not_to have_css("img")
        end
      end
    end
  end
end

