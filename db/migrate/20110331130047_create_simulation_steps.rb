class CreateSimulationSteps < ActiveRecord::Migration
  def self.up
    create_table :simulation_steps do |t|
      t.integer :simulation_id
      t.text :data_json
      t.integer :step_no

      t.timestamps
    end
  end

  def self.down
    drop_table :simulation_steps
  end
end
