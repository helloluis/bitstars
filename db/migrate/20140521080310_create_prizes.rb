class CreatePrizes < ActiveRecord::Migration
  def change
    create_table :prizes do |t|
      t.integer :user_id
      t.integer :photo_id
      t.float   :amount_in_sats
      t.boolean :revoked, default: false
      t.timestamps
    end

    add_index :prizes, [ :user_id, :photo_id ]
  end
end
