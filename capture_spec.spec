require_relative 'spec_helper'
require_relative 'capture'

RSpec.describe VideoScreenshot::Capture do
  let(:chrome_path) { '/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome' }
  let(:logger) { Logger.new(STDOUT) }
  let(:url) { 'https://staging.events.taogroup.com' }
  let(:directory) { 'staging' }
  let(:label) { 'Staging' }
  let(:capture) { described_class.new(chrome_path, logger) }

  before do
    allow(Time).to receive(:now).and_return(Time.new(2023, 6, 16, 12, 0, 0, "-07:00")) # Pacific Time
    allow(FileUtils).to receive(:mkdir_p)
    allow(capture).to receive(:system)
    allow(File).to receive(:directory?).and_return(false)
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end

  it 'takes a screenshot' do
    capture.take_screenshot(url, directory, label)

    expect(FileUtils).to have_received(:mkdir_p).with(directory)
    expect(capture).to have_received(:system)
    expect(logger).to have_received(:info)
  end
end
