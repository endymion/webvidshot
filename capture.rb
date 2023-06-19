require 'logger'
require 'fileutils'
require 'active_support/time'
require 'timeout'

module VideoScreenshot
  class Capture
    def initialize(chrome_path, logger)
      @logger = logger
      @chrome_path = find_chrome_path(chrome_path)
    end

    def take_screenshot(url, directory, label)
      FileUtils.mkdir_p(directory) unless File.directory?(directory)

      timestamp = Time.now.in_time_zone('Pacific Time (US & Canada)')
      filename_timestamp = timestamp.strftime("%Y-%m-%d_%H-%M-%S")
      screenshot_path = "#{directory}/screenshot_#{filename_timestamp}.png"

      begin
        Timeout::timeout(300) do  # set a timeout of 300 seconds (5 minutes)
          system("#{@chrome_path} --headless --disable-gpu --disable-3d-apis --disable-dev-shm-usage --virtual-time-budget=100000 --run-all-compositor-stages-before-draw --window-size=3840,2160 --screenshot=#{screenshot_path} #{url}")
        end

        @logger.info("#{label} screenshot taken at #{timestamp}")
      rescue Timeout::Error
        @logger.error("Screenshot process for #{url} took too long and was terminated.")
      rescue => e
        @logger.error("Error: #{e}")
      end
    end

    private

    # Find the path to Chrome executable by trying some common locations.
    # Allow the user to override it manually with the --chrome_path option,
    # but test the path they provide to see if it's there.
    # Warn them if we can't find it.
    def find_chrome_path(chrome_path)
      if chrome_path
        if File.exist?(chrome_path)
          @logger.info("Using Chrome executable at #{chrome_path}")
          return chrome_path
        else
          @logger.warn("Chrome executable not found at #{chrome_path}.  Using default location.")
        end
      end

      # Try some common locations for Chrome executable
      chrome_paths = [
        # Downloaded with https://github.com/scheib/chromium-latest-linux/blob/master/update.sh
        # Because of https://support.google.com/chrome/thread/206429303/chrome-headless-screenshot-not-respecting-window-size-anymore?hl=en
        '1159673/chrome-linux/chrome',

        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
        '/Applications/Chromium.app/Contents/MacOS/Chromium',
        '/usr/bin/google-chrome',
        '/usr/bin/chromium',
      ]

      chrome_paths.each do |path|
        if File.exist?(path)
          @logger.info("Using Chrome executable at #{path}")
          return path
        end
      end

      @logger.error("Chrome executable not found.  Please install Chrome or Chromium and try again.")
      exit
    end


  end
end
