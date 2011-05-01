class CreateSimulations < ActiveRecord::Migration
  def self.up
    create_table :simulations do |t|
      t.string :name
      t.binary :map_json
      t.binary :actors_json

      t.timestamps
    end
  end

  def self.down
    drop_table :simulations
  end
end
