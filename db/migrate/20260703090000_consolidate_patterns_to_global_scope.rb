# frozen_string_literal: true

class ConsolidatePatternsToGlobalScope < ActiveRecord::Migration[6.0]
  def up
    add_index :patterns, :match_text unless index_exists?(:patterns, :match_text)

    # Existing account-scoped patterns become globally shared.
    execute 'UPDATE patterns SET account_id = NULL'
  end

  def down
    remove_index :patterns, :match_text if index_exists?(:patterns, :match_text)
  end
end
