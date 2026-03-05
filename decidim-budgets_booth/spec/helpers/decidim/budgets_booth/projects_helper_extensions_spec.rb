# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::ProjectsHelperExtensions, type: :helper do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:step_one) do
    create(:participatory_process_step,
           active: true,
           end_date: Time.zone.now.to_date,
           participatory_process:)
  end
  let!(:step_two) do
    create(:participatory_process_step,
           active: false,
           end_date: 1.month.from_now.to_date,
           participatory_process:)
  end

  before do
    allow(helper).to receive_messages(current_organization: organization, params: { participatory_process_slug: participatory_process.slug })
  end

  describe "#projects_container_class" do
    context "when view mode is grid" do
      let(:view_mode) { "grid" }

      it "returns the grid class" do
        expect(helper.projects_container_class(view_mode)).to eq("card__grid-grid")
      end
    end

    context "when view mode is list" do
      let(:view_mode) { "list" }

      it "returns the list class" do
        expect(helper.projects_container_class(view_mode)).to eq("card__list-list")
      end
    end
  end

  describe "#card_size_for_view_mode" do
    context "when view mode is grid" do
      let(:view_mode) { "grid" }

      it "returns the grid symbol" do
        expect(helper.card_size_for_view_mode(view_mode)).to eq(:g)
      end
    end

    context "when view mode is list" do
      let(:view_mode) { "list" }

      it "returns the list symbol" do
        expect(helper.card_size_for_view_mode(view_mode)).to eq(:l)
      end
    end
  end
end
