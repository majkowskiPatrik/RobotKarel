class CreateSimulations < ActiveRecord::Migration
  def self.up
    create_table :simulations do |t|
      t.string :name
      t.text :map_json
      t.text :actors_json

      t.timestamps
    end
  end

  def self.down
    drop_table :simulations
  end
end
