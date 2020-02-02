# frozen_string_literal: true

require 'test/unit/testcase'
require 'test/unit' if $PROGRAM_NAME == __FILE__
require 'image_science'

class TestImageScience < Test::Unit::TestCase
  def deny(x)
    assert !x
  end

  def similar_image?(w, h, img)
    assert_kind_of ImageScience, img
    assert_equal h, img.height
    assert_equal w, img.width
  end

  def setup
    @path = 'test/pix.png'
    @tmppath = 'test/pix-tmp.png'
    @h = @w = 50
  end

  def teardown
    File.unlink @tmppath if File.exist? @tmppath
  end

  def test_class_with_image
    ImageScience.with_image @path do |img|
      similar_image? @w, @h, img
      assert img.save(@tmppath)
    end

    ImageScience.with_image(@tmppath) { |img| similar_image? @w, @h, img }
  end

  def test_class_with_image_missing
    assert_raises ArgumentError do
      ImageScience.with_image("#{@path}nope") { flunk }
    end
  end

  def test_class_with_image_missing_with_img_extension
    assert_raises ArgumentError do
      ImageScience.with_image("nope#{@path}") { flunk }
    end
  end

  def test_class_with_image_return_nil_on_bogus_image
    File.open(@tmppath, 'w') { |f| f << 'bogus image file' }
    assert_nil ImageScience.with_image(@tmppath) { flunk }
  end

  def test_resize
    ImageScience.with_image @path do |img|
      img.resize(25, 25) { |thumb| assert thumb.save(@tmppath) }
    end

    ImageScience.with_image(@tmppath) { |img| similar_image? 25, 25, img }
  end

  def test_resize_floats
    ImageScience.with_image @path do |img|
      img.resize(25.2, 25.7) { |thumb| assert thumb.save(@tmppath) }
    end

    ImageScience.with_image(@tmppath) { |img| similar_image? 25, 25, img }
  end

  def test_resize_zero
    [[0, 25], [25, 0], [0, 0]].each do |w, h|
      assert_raises ArgumentError do
        ImageScience.with_image @path do |img|
          img.resize(w, h) { |thumb| assert thumb.save(@tmppath) }
        end
      end

      deny File.exist?(@tmppath)
    end
  end

  def test_resize_negative
    [[-25, 25], [25, -25], [-25, -25]].each do |w, h|
      assert_raises ArgumentError do
        ImageScience.with_image @path do |img|
          img.resize(w, h) { |thumb| assert thumb.save(@tmppath) }
        end
      end

      deny File.exist?(@tmppath)
    end
  end

  def test_image_format_retrieval
    ImageScience.with_image @path do |img|
      assert_equal 'PNG', img.format
    end
  end

  def test_image_format_retrieval_from_bytes
    ImageScience.with_image @path do |img|
      bytes_string = img.bytes('JPEG')
      image = ImageScience.with_bytes(bytes_string)
      assert_equal 'JPEG', image.format
      assert_kind_of java.awt.image.BufferedImage, image.to_java
    end
  end

  def test_image_format_retrieval_fail_when_invalid_bytes
    image = ImageScience.with_bytes('some invalid image bytes')
    assert_equal nil, image.format
  end

  def test_cmyk_jpeg_image_reading
    assert_nothing_raised do
      image = ImageScience.with_image('test/pix_cmyk.jpg')
      assert_equal 'JPEG', image.format
      assert_kind_of java.awt.image.BufferedImage, image.to_java
    end
  end

  def test_saving_gif_with_explicit_quality
    @tmppath = 'test/pix-tmp.gif'
    ImageScience.with_image @path do |img|
      new_img = img.quality(0.8)
      assert new_img.save(@tmppath)
    end

    assert File.exist?(@tmppath)
  end
end
