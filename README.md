[![Build Status](https://travis-ci.org/ruby-av/paperclip-av-chainer.svg?branch=master)](https://travis-ci.org/ruby-av/paperclip-av-chainer)
# Paperclip Chainer

Audio/Video Chainer for Paperclip using FFMPEG/Avconv.

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-av-chainer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-av-chainer

## Usage

```ruby
# app/models/user.rb
class Post < ActiveRecord::Base
  has_attached_file :audio, :styles => {
    :medium => { :geometry => "640x480", :format => 'ogg' },
  }, :processors => [:chainer]
end
```
Now when you attach archives (see supported formats) containing audio files, they will
all be concatenated in one file.

### Supported Formats

Currently supported input archives:

    * ZIP

Concatenting audio files tested:

    * OGG
    * SPX

## Contributing

1. Fork it ( https://github.com/[my-github-username]/paperclip-av-chainer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
