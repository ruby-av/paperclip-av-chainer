require 'spec_helper'

describe Paperclip::Chainer do
  let(:subject) { Paperclip::Chainer.new(source) }
  let(:document) { Document.create(original: Rack::Test::UploadedFile.new(source, 'application/zip')) }
  let(:source) { File.new(File.expand_path('spec/support/assets/audio.zip')) }
  
  it { expect(File.exists?(document.original.path(:small))).to eq true }
  
  describe ".unzip" do
    before do
      subject.unzip
    end
    
    it { expect(Dir["#{subject.destination}/*"].count).to eq 2 }
  end
end