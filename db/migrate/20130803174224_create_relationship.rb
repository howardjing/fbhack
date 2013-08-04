class CreateRelationship < ActiveRecord::Migration
 def change
  	create_table :relationships do |t|
      t.decimal :amount
      t.integer :from_id
      t.integer :to_id
      t.string :users_involved
    end
  end
end
