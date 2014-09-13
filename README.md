# Paperclip Chainer

Audio/Video Chainer for Paperclip using FFMPEG/Avconv.

## Status

[![Build Status](https://travis-ci.org/ruby-av/paperclip-av-chainer.svg?branch=master)](https://travis-ci.org/ruby-av/paperclip-av-chainer)
[![Coverage Status](https://coveralls.io/repos/ruby-av/paperclip-av-chainer/badge.png?branch=master)](https://coveralls.io/r/ruby-av/paperclip-av-chainer?branch=master)
[![Code Climate](https://codeclimate.com/github/ruby-av/paperclip-av-chainer/badges/gpa.svg)](https://codeclimate.com/github/ruby-av/paperclip-av-chainer)
[![Dependency Status](https://gemnasium.com/ruby-av/paperclip-av-chainer.svg)](https://gemnasium.com/ruby-av/paperclip-av-chainer)

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-av-chainer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-av-chainer

## Usage

    # app/models/user.rb
    class Post < ActiveRecord::Base
      has_attached_file :audio, :styles => {
        :medium => { :geometry => "640x480", :format => 'ogg' },
      }, :processors => [:chainer]
    end

Now when you attach archives (see supported formats) containing audio files, they will
all be concatenated in one file.

### Supported Formats

Currently supported input archives:

    * ZIP

Concatenting audio files tested:

    * OGG
    * SPX

## Contributing

1. Fork it ( https://github.com/ruby-av/paperclip-av-chainer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
