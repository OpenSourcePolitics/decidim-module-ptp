# frozen_string_literal: true

require "decidim/budgets_booth/engine"
require_relative "budgets_booth/workflows"

module Decidim
  # This namespace holds the logic of the `BudgetsBooth` component. This component
  # allows users to create budgets_booth in a participatory space.
  module BudgetsBooth
    autoload :VotingExtensions, "decidim/budgets_booth/voting_extensions"
    autoload :ScopeManager, "decidim/budgets_booth/scope_manager"
    include ActiveSupport::Configurable
    # Default configuration digits to generate the zip code.
    config_accessor :zip_code_length do
      5
    end
  end
end
