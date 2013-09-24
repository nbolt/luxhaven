class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  #storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process :resize_to_fill => [800, 540]
  process :convert => 'jpg'
  #
  # def scale(width, height)
  #   # do something
  # end

  #version :gallery do
  #  process :resize_to_fill => [675, 455]
  #end
  
  version :large_thumb do
    process :resize_to_fill => [160, 160]
    process :convert => 'jpg'
  end

  version :thumb do
    process :resize_to_fill => [64, 64]
    process :convert => 'jpg'
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  #def extension_white_list
  #  %w(jpg jpeg gif png)
  #end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
  end

end
