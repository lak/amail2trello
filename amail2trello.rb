#!/usr/bin/env ruby

require 'trello'
include Trello

subject = ARGV[0]
id = ARGV[1]
message = ARGV[2]

# There's a little setup involved here.

# Step 1. Get Your Application Key from here:
# https://trello.com/1/appKey/generate
public_key = ""

# Step 2. Get Your Token to Approve Your "App" from here:
# https://trello.com/1/authorize?key=YOUR_APPLICATION_KEY_FROM_STEP_1&name=SOME_ARBITRARY_NAME&expiration=never&response_type=token&scope=read,write
member_token = ""

# Step 3. Set up misc. variables
board_name = ""
list_name = ""
username = ""


Trello.configure do |config|
  config.developer_public_key = public_key
  config.member_token =  member_token
end

user = Member.find(username)
board = user.boards.select { |b| b.name == board_name }.first
list = board.lists.select { |l| l.name == list_name }.first
  
message_id =  CGI.escape(id)

card = Card.create(:name => subject, :desc => "message://%3c#{id}%3e\n\n#{message}", :list_id => list.id)




