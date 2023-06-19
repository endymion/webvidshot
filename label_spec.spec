require_relative 'spec_helper'
require_relative 'label'

RSpec.describe VideoScreenshot::Labeler do
  let(:logger) { Logger.new(STDOUT) }
  let(:directory) { 'staging' }
  let(:labeler) { described_class.new(logger) }
  let(:image) { double("Magick::Image") }
  let(:draw) { double("Magick::Draw") }
  
  before do
    allow(labeler).to receive(:watch_directories)
    allow(labeler).to receive(:label_images).and_call_original
    allow(File).to receive(:directory?).and_return(false)
    allow(FileUtils).to receive(:mkdir_p)
    allow(Dir).to receive(:glob).and_return(['staging/screenshot_2023-06-17_13-18-56.png'])
    allow(File).to receive(:exist?).and_return(false)
    allow(Magick::Image).to receive_message_chain(:read, :first).and_return(image)
    allow(image).to receive(:write)
    allow(logger).to receive(:info)
    allow(Magick::Draw).to receive(:new).and_return(draw)
    allow(draw).to receive(:fill=)
    allow(draw).to receive(:pointsize=)
    allow(draw).to receive(:gravity=)
    allow(draw).to receive(:annotate)
  end

  it 'labels images' do
    labeler.label_images(directory)

    expect(FileUtils).to have_received(:mkdir_p)
    expect(Dir).to have_received(:glob)
    expect(logger).to have_received(:info).twice
  end
end
