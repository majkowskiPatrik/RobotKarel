class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
      t.string :name
      t.binary :data

      t.timestamps
    end
  end

  def self.down
    drop_table :maps
  end
end
