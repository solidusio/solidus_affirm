class AddAffirmProviderToAffirmCheckouts < ActiveRecord::Migration[6.0]
  def change
    add_column :affirm_checkouts, :provider, :string, default: :affirm
  end
end
