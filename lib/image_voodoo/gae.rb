# frozen_string_literal: true

# Google App Engine implementation (does this work?)
class ImageVoodoo
  java_import com.google.appengine.api.images.Image
  java_import com.google.appengine.api.images.ImagesService
  java_import com.google.appengine.api.images.ImagesServiceFactory
  java_import com.google.appengine.api.images.Transform

  ImageService = ImagesServiceFactory.images_service

  #--
  # Value Add methods for this backend
  #++

  ##
  # *GAE* Automatically adjust contrast and color levels.
  def i_am_feeling_lucky
    transform(ImagesServiceFactory.make_im_feeling_lucky)
  end

  #--
  # Implementations of standard features
  #++

  class << self
    private

    def with_bytes_impl(bytes)
      image = ImageServicesFactory.make_image(bytes)
      ImageVoodoo.new bytes, image, image.format.to_s.upcase
    end
  end

  private

  def flip_horizontally_impl
    transform(ImagesServiceFactory.make_horizontal_flip)
  end

  def flip_vertically_impl
    transform(ImagesServiceFactory.make_vertical_flip)
  end

  def resize_impl(width, height)
    transform(ImagesServiceFactory.make_resize(width, height))
  end

  def with_crop_impl(left, top, right, bottom)
    transform(ImagesServiceFactory.make_crop(left, top, right, bottom))
  end

  def from_java_bytes
    String.from_java_bytes @src.image_data
  end

  #
  # Make a duplicate of the underlying src image
  #
  def dup_src
    ImageServicesFactory.make_image(from_java_bytes)
  end

  def transform(transform, target=dup_src)
    ImageService.apply_transform(transform, target)
  end
end
