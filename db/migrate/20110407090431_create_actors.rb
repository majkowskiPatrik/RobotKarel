class CreateActors < ActiveRecord::Migration
  def self.up
    create_table :actors do |t|
      t.string :name
      t.text :source_code
      t.text :static_code

      t.timestamps
    end
  end

  def self.down
    drop_table :actors
  end
end