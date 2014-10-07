require 'zip'
require 'av'

module Paperclip
  class Chainer < Processor
    attr_accessor :file, :whiny, :destination, :extension, :basename, :supported_formats
    
    def initialize file, options = {}, attachment = nil
      @file = file
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @destination = Pathname.new("#{Dir.tmpdir}/#{SecureRandom.uuid}")
      @extension  = File.extname(@file.path)
      @basename = File.basename(@file.path, @extension)
      @supported_formats = ['.zip']
    end
    
    def make
      if @supported_formats.include?(@extension)
        log "Received supported file #{@file.path}"
        case @extension
        when '.zip'
          unzip
        end
        result = concatenate
        log "Successfully concatenated source into #{result.path}"
        # Explicitly return in order to allow the next processor in the chain to work
        # on the new file
        return result
      end
      log "Skipping file with unsupported format: #{@file.path}"
      # If the file is not supported, just return it
      @file
    end
    
    def unzip
      if @supported_formats.include?(@extension)
        log "Extracting contents to #{@destination}"
        Zip::File.open(File.expand_path(@file.path)) do |zip_file|
          log "Creating #{@destination}"
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
    end
    
    def concatenate
      list = Dir["#{@destination}/*"]
      target = Tempfile.new(['chainer-', @target_format])
      log "Concatentating #{list.inspect} from #{@destination} into #{target.path}"
      begin
        cli = ::Av.cli(log: true)
        cli.reset_input_filters
        cli.filter_concat(list)
        cli.add_destination(target.path)
        cli.run
        return target
      rescue Cocaine::ExitStatusError => e
        raise Paperclip::Error, "error while concatenating video for #{@file.path}: #{e}" if @whiny
      end
    end
    
    def log message
      Paperclip.log "[chainer] #{message}"
    end
  end
end