require 'thor'
require_relative 'capture'
require_relative 'label'
require_relative 'generate_video'
require 'logger'

module VideoScreenshot
  class CLI < Thor
    desc "capture URL [ENVIRONMENT]", "Capture web screenshots and make a video."
    long_desc <<-LONGDESC
    Start capturing screenshots of the given URL and keep going indefinitely.  Label each new screenshot with a timestamp and the name of the environment, "screenshots" by default.  Generate a video of the screenshots and keep updating it when new files appear or when any other changes happen to the enivronment's screenshot directory.
    LONGDESC
    method_option :chrome_path, default: '/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome', desc: "Path to Chrome executable"
    method_option :label, default: 'true', desc: "Start the labeling process to label screenshots with timestamps"
    method_option :video, default: 'true', desc: "Start the video generation process to update generated videos when new files appear or when any other changes happen to the enivronment's screenshot directory"
    def capture(url, environment = 'screenshots')
      # initialize logger
      logger = Logger.new(STDOUT)

      capture = Capture.new(options[:chrome_path], logger)

      if options[:label]
        # Start the labeler as a separate process
        Process.fork do
          labeler = Labeler.new(logger)
          labeler.watch_directories([environment])
        end
      end

      if options[:video]
        # Start the video generator as a separate process
        Process.fork do
          video_generator = VideoGenerator.new(logger)
          video_generator.watch_directories([environment])
        end
      end
      
      # infinite loop that continuously captures screenshots
      loop do
        logger.info("Taking screenshot of #{url}...")
        capture.take_screenshot(url, environment, environment.capitalize)
      end
    end

    desc "label [ENVIRONMENT]", "Label screenshots with timestamps and watch."
    long_desc <<-LONGDESC
      Label existing screenshots with timestamps, and watch for new screenshots to label.
    LONGDESC
    method_option :watch, default: 'true', desc: "Watch for changes over time and keep updating labels when new files appear or when any other changes happen to the enivronment's screenshot directory"
    def label(environment = 'screenshots')
      # initialize logger
      logger = Logger.new(STDOUT)

      # Start the labeler
      labeler = Labeler.new(logger)
      labeler.label_images(environment)

      # Watch for changes if the option is set.
      if options[:watch]
        labeler.watch_directories([environment])
      end
    end

    desc "video [ENVIRONMENT]", "Make a video and keep it updated."
    long_desc <<-LONGDESC
      Watch for changes to the screenshot directory and generate a video when new files appear or when any other changes happen to the environment's screenshot directory.
    LONGDESC
    def video(environment = 'screenshots')
      # initialize logger
      logger = Logger.new(STDOUT)

      # Start the video generator
      video_generator = VideoGenerator.new(logger)
      video_generator.create_video(environment)
      video_generator.watch_directories([environment])
      
    end
  end
end

VideoScreenshot::CLI.start(ARGV)
