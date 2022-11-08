#!/usr/bin/env ruby

require 'dotenv/load'
require 'pry'
require 'logger'
require 'mail'
require 'bunny'
require 'faraday'
require 'xmlhash'
require 'json'
require 'digest'

require_relative 'lib/logging'
require_relative 'lib/amqp'
require_relative 'lib/obs'
require_relative 'lib/openqa'
require_relative 'lib/slack'
require_relative 'lib/trello'

include Logging

class Kurren
  def initialize
    super
    @amqp = Amqp.new
  end

  def start
    @amqp.broker
    loop do
      sleep 1.0
    end
  end
end

@kurren = Kurren.new
# binding.pry
@kurren.start

