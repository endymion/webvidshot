require 'pry'
require 'fileutils'
require 'pathname'
require 'active_support/time'
require 'rmagick'
require 'filewatcher'
require 'logger'

module VideoScreenshot
  class Labeler
    attr_reader :logger

    def initialize(logger = Logger.new(STDOUT))
      @logger = logger
    end

    def watch_directories(directories)
      Filewatcher.new(directories).watch do |event|
        logger.info("Filewatcher event: #{event}")
        filename = event.first.first
        directory = Pathname.new(filename).dirname.to_s
        logger.info("Labelling images in #{directory}.")
        label_images(directory)
      end
    end

    def label_images(directory)
      labeled_dir = "#{directory}/labeled"
      FileUtils.mkdir_p(labeled_dir) unless File.directory?(labeled_dir)

      Dir.glob("#{directory}/screenshot_*.png").each do |screenshot_path|
        labeled_screenshot_path = screenshot_path.gsub(directory, labeled_dir)

        logger.info("Checking for labeled image #{File.basename(screenshot_path)} in #{directory}...")

        unless File.exist?(labeled_screenshot_path)
          logger.info("Creating labeled image for #{screenshot_path}...")
          image = Magick::Image.read(screenshot_path).first
          draw = Magick::Draw.new

          draw.fill = 'white'
          draw.pointsize = 200
          draw.gravity = Magick::NorthWestGravity

          timestamp_from_file = File.basename(screenshot_path).gsub(/^[^\_]+\_/,'').gsub(/\.png$/,'')
          readable_timestamp = Time.strptime(timestamp_from_file, "%Y-%m-%d_%H-%M-%S").strftime("%Y-%m-%d %I:%M:%S %p PT")

          draw.annotate(image, 0, 0, 150, 150, readable_timestamp)

          draw.gravity = Magick::NorthEastGravity
          draw.annotate(image, 0, 0, 150, 150, directory.upcase)

          image.write(labeled_screenshot_path)
          logger.info("labeled image file #{File.basename(screenshot_path)} in #{directory}")
        end
      end
    end
  end
end
