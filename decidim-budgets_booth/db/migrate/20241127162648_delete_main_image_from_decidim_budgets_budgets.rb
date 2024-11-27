# frozen_string_literal: true

class DeleteMainImageFromDecidimBudgetsBudgets < ActiveRecord::Migration[7.0]
  def up
    remove_column :decidim_budgets_budgets, :main_image
  end

  def down
    add_column :decidim_budgets_budgets, :main_image, :string
  end
end
