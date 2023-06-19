require 'pry'
require 'fileutils'
require 'pathname'
require 'filewatcher'
require 'logger'

module VideoScreenshot
  class VideoGenerator
    attr_reader :logger

    def initialize(logger = Logger.new(STDOUT))
      @logger = logger
    end

    def create_video(directory)
      video_dir = File.join(directory, 'labeled')
      FileUtils.mkdir_p(video_dir) unless File.directory?(video_dir)
      
      video_path = "#{video_dir}/#{directory}.mp4"
      
      # Create video from labeled screenshots
      @logger.info("Creating video for #{directory}...")
      if system("ffmpeg -y -framerate 2 -i #{directory}/labeled/screenshot_%*.png -c:v libx264 -r 30 -pix_fmt yuv420p #{video_path}")
        @logger.info("#{directory} video created at #{video_path}")
      else
        @logger.error("Error creating video for #{directory}")
      end
    end

    def watch_directories(directories)
      @logger.info("Watching directories #{directories} for changes...")
      Filewatcher.new(directories).watch do |event|
        @logger.info("Filewatcher event: #{event}")
        filename = event.first.first
        directory = Pathname.new(filename).dirname.to_s
        @logger.info("Creating video for #{directory}.")
        create_video(directory)
      end
    end

  end

end
