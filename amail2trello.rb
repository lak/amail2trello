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
      warn "See the example file at trello.conf.example"
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

file = ARGV[0] # The path to the complicated source
subject = ARGV[1]
id = ARGV[2]
message = ARGV[3] # this is a simplified form of the text

unless file =~ /^\// # It's a wonky OSX-style path
  file = file.sub(/[^:]+/, '').gsub(":", "/")
end

source = File.read(file)
File.unlink(file) # clean up after ourselves.  There's still a timing attack, but at least it's small(ish)

attachments = []

# Currently we only support google docs, but we could support others, right?
source.scan(/https\:\/\/docs\.google\.com\/\S+/).each do |url|
  next unless url.include?("document") # I think we're matching a bunch of split-line html stuff
  attachments << url
end

File.open("/tmp/content.txt", "w") { |f| f.print source }

user = Member.find(config.user)
board = user.boards.select { |b| b.name == config.board }.first
list = board.lists.select { |l| l.name == config.list }.first
  
message_id =  CGI.escape(id)

begin
  card = Card.create(
    :name => subject,
    :desc => "message://%3c#{id}%3e\n\n#{message}",
    :list_id => list.id,
    :pos => "bottom"
  )
rescue => detail
  raise "Could not create Trello card: #{detail}"
end

unless attachments.empty?
  attachments.sort.uniq.each do |url|
    card.add_attachment(url)
  end
end
puts card.short_url

# This will take you to the card's page
# Turns out, actually, this is pretty annoying. Disabling
# system("open #{card.short_url}")

