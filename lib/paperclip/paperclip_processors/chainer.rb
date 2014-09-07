require 'zip'
require 'av'

module Paperclip
  class Chainer < Processor
    def initialize file, options = {}, attachment = nil
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @file = file
      @extension  = File.extname(@file.path)
      @basename = File.basename(@file.path, @extension)
      @index_name = 'input.txt'
      @supported_formats = ['.zip']
    end
    
    def make
      if @supported_formats.include?(@extension)
        Paperclip.log "[chainer] Got file with extension #{@extension}"
        uuid = SecureRandom.uuid
        destination = Rails.root.join('tmp', 'ogg_chainer', uuid)
        Paperclip.log "[chainer] Extracting contents to #{destination}"
        case @extension
        when '.zip'
          unzip destination
          # create_index destination
          result = concatenate(destination)
        end
        Paperclip.log "[chainer] Successfully concatenated source into #{result.path}"
        # Explicitly return in order to allow the next processor in the chain to work
        # on the new file
        return result
      end
      @file
    end
    
    def unzip destination
      Zip::File.open(@file.path) do |zip_file|
        Paperclip.log "[chainer] Creating #{destination}"
        FileUtils.mkdir_p(destination)
        zip_file.each do |source|
          # Extract to file/directory/symlink
          Paperclip.log "[chainer] Extracting #{source.name}"
          target_file = destination.join(source.name)
          @target_format = File.extname(source.name)
          zip_file.extract(source, target_file) unless File.exists?(target_file)
        end
      end
    end
    
    def create_index destination
      Dir.chdir(destination) do
        File.open(@index_name, 'w') do |index|
          list = Dir[File.join(destination, '**', '**')]
          list.delete(File.join(destination, @index_name))
          list.each do |file|
            index.write("file '#{file}'\n")
          end
        end
      end
    end
    
    def concatenate destination
      list = Dir["#{destination}*"]
      file = Tempfile.new(['ogg-chainer-', @target_format])
      Paperclip.log "[chainer] Concatentating #{destination} into #{file.path}"
      begin
        ::Av.cli.filter_concat(list)
        ::Av.cli.add_destination(file.path)
        ::Av.cli.run
        return file.path
      rescue Cocaine::ExitStatusError => e
        raise Paperclip::Error, "error while concatenating video for #{@basename}: #{e}" if @whiny
      end
    end
  end
end