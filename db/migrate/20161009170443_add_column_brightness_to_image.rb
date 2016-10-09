class AddColumnBrightnessToImage < ActiveRecord::Migration
  def change
  	add_column :images, :brightness, :integer, array: true
  end
end
