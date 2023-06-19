require 'logger'
require 'fileutils'
require 'active_support/time'
require 'timeout'

module VideoScreenshot
  class Capture
    def initialize(chrome_path, logger)
      @chrome_path = chrome_path
      @logger = logger
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
  end
end
