class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :main_image
      t.string :processing_image
      t.string :filter_image 
      t.timestamps null: false
    end
  end
end
