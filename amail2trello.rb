#!/usr/bin/env ruby

require 'trello'
include Trello

CONFIG_FILE = File.expand_path("~/.trello.conf")

class TrelloConfig

  # Step 1. Get Your Application Key from here:
  # https://trello.com/1/appKey/generate

  # Step 2. Get Your Token to Approve Your "App" from here:
  # https://trello.com/1/authorize?key=YOUR_APPLICATION_KEY_FROM_STEP_1&name=SOME_ARBITRARY_NAME&expiration=never&response_type=token&scope=read,write

  # Step 3. Set up misc. variables

  @params = ["public_key", "member_token", "board", "list", "user"]

  def self.configure
    config = self.new

    Trello.configure do |trello_config|
      trello_config.developer_public_key = config.public_key
      trello_config.member_token =  config.member_token
    end

    config
  end

  def self.params
    @params.dup
  end

  @params.each { |p| attr_accessor p }

  def initialize
    load_config(self)
  end

  def load_config(config)
    unless File.exist?(CONFIG_FILE)
      warn "You have to create a trello config file at #{CONFIG_FILE}"
      warn "See the example file at <fill this in>"
      exit(1)
    end

    File.readlines(CONFIG_FILE).each do |line|
      line.chomp!
      next if line =~ /^#/ # skip comments
      next if line =~ /^\s*$/ # skip blank lines

      key, value = line.split(/:\s+/) # foo: bar

      unless key and value
        raise "Invalid format '#{line}'; expecting 'key: value'"
      end

      begin
        config.send(key + "=", value)
      rescue
        raise "Invalid parameter '#{key}'; supported params are '#{Config.params.join(", ")}'"
      end
    end
  end
end

config = TrelloConfig.configure

subject = ARGV[0]
id = ARGV[1]
message = ARGV[2]

user = Member.find(config.user)
board = user.boards.select { |b| b.name == config.board }.first
list = board.lists.select { |l| l.name == config.list }.first
  
message_id =  CGI.escape(id)

card = Card.create(:name => subject, :desc => "message://%3c#{id}%3e\n\n#{message}", :list_id => list.id, :pos => "bottom")
puts card.short_url

# This will take you to the card's page
system("open #{card.short_url}")

