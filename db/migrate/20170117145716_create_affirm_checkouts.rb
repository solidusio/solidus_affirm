class CreateAffirmCheckouts < ActiveRecord::Migration
  def change
    create_table :affirm_checkouts do |t|
      t.string :token
      t.timestamps
    end
  end
end
