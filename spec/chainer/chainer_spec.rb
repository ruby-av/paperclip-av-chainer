require 'spec_helper'

describe Paperclip::Chainer do
  let(:supported) { File.new(File.expand_path('spec/support/assets/audio.zip')) }
  let(:unsupported) { File.new(File.expand_path('spec/support/assets/image.png')) }
  
  describe "supported formats" do
    let(:subject) { Paperclip::Chainer.new(supported) }
    let(:document) { Document.create(audio: Rack::Test::UploadedFile.new(supported, 'application/zip')) }
    
    it { expect(File.exists?(document.audio.path(:small))).to eq true }
  
    describe ".unzip" do
      before do
        subject.unzip
      end
    
      it { expect(Dir["#{subject.destination}/*"].count).to eq 2 }
    end
  end
  describe "unsupported formats" do
    let(:subject) { Paperclip::Chainer.new(unsupported) }
    let(:document) { Document.create(image: Rack::Test::UploadedFile.new(unsupported, 'image/png')) }
    
    it { expect(File.exists?(document.image.path(:small))).to eq true }
  
    describe ".unzip" do
      before do
        subject.unzip
      end
    
      it { expect(Dir["#{subject.destination}/*"].count).to eq 0 }
    end
  end
end