class CreateTranscodes < ActiveRecord::Migration
  def self.up
    create_table :transcodes do |t|
      t.string :directory
      t.datetime :completed
      t.integer :series_total
      t.datetime :started
      t.string :type
      t.integer :series_count

      t.timestamps
    end
  end

  def self.down
    drop_table :transcodes
  end
end
