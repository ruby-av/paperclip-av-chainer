require 'zip'
require 'av'

module Paperclip
  class Chainer < Processor
    attr_accessor :whiny, :destination, :extension, :basename, :supported_formats
    
    def initialize file, options = {}, attachment = nil
      Paperclip.log "[chainer] Got file #{file.path}"
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @file = file
      @extension  = File.extname(@file.path)
      @basename = File.basename(@file.path, @extension)
      @supported_formats = ['.zip']
      @destination = Pathname.new("#{Dir.tmpdir}/#{SecureRandom.uuid}")
    end
    
    def make
      if @supported_formats.include?(@extension)
        Paperclip.log "[chainer] Got file #{@file.path} with extension #{@extension}"
        case @extension
        when '.zip'
          unzip
        end
        result = concatenate
        Paperclip.log "[chainer] Successfully concatenated source into #{result.path}"
        # Explicitly return in order to allow the next processor in the chain to work
        # on the new file
        return result
      end
      # If the file is not supported, just return it
      @file
    end
    
    def unzip
      Paperclip.log "[chainer] Extracting contents to #{@destination}"
      Zip::File.open(File.expand_path(@file.path)) do |zip_file|
        Paperclip.log "[chainer] Creating #{@destination}"
        FileUtils.mkdir_p(@destination)
        zip_file.each do |source|
          # Extract to file/directory/symlink
          Paperclip.log "[chainer] Extracting #{source.name}"
          target_file = @destination.join(source.name)
          @target_format = File.extname(source.name)
          zip_file.extract(source, target_file) unless File.exists?(target_file)
        end
      end
    end
    
    def concatenate
      list = Dir["#{@destination}/*"]
      target = Tempfile.new(['chainer-', @target_format])
      Paperclip.log "[chainer] Concatentating #{list.inspect} from #{@destination} into #{target.path}"
      begin
        cli = ::Av.cli
        cli.reset_input_filters
        cli.filter_concat(list)
        cli.add_destination(target.path)
        cli.run
        return target
      rescue Cocaine::ExitStatusError => e
        raise Paperclip::Error, "error while concatenating video for #{@file.path}: #{e}" if @whiny
      end
    end
  end
end