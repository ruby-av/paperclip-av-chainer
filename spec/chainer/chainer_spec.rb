require 'spec_helper'

describe Paperclip::Chainer do
  let(:subject) { Paperclip::Chainer.new(source) }
  let(:source) { File.new(Dir.pwd + '/spec/support/assets/audio.zip') }
  let(:destination) { Pathname.new("#{Dir.tmpdir}/chainer/") }
  
  describe ".unzip" do
    before do
      FileUtils.rm_rf(destination)
      subject.unzip(destination)
    end
    
    it { expect(Dir["#{destination}/*"].count).to eq 2 }
  end

  # describe ".create_index" do
  #   before do
  #     FileUtils.rm_rf(destination)
  #     subject.create_index(destination)
  #   end
  #
  #   it { expect(File.foreach("#{destination}input.txt").inject(0) {|c, line| c+1}).to eq 2 }
  # end

  describe ".concatenate" do
    let(:output) do
      subject.unzip(destination)
      subject.concatenate(destination) 
    end
    
    it { expect(File.exists?(output)).to eq true }
  end
end