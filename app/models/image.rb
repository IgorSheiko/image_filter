class Image < ActiveRecord::Base
  mount_uploader :main_image, ImageUploader
  mount_uploader :processing_image, ImageUploader
  mount_uploader :filter_image, ImageUploader
end
