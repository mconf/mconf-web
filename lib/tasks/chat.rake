require 'yaml'
require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/roster'
require 'xmpp4r/client'
require 'xmpp4r/muc/x/muc'
require 'xmpp4r/muc/iq/mucowner'
require 'xmpp4r/muc/iq/mucadmin'
require 'xmpp4r/dataforms'

namespace :chat do

  desc "Read all strings ENV['LOCALE'] and saves them sorted and with standard YAML formatting"
  task :create_space_mucs => :environment do
    @spaces = Space.order('name ASC').all
    presence_domain = ENV['PRESENCE_DOMAIN']
    puts "Starting..."
    @spaces.each do |space|
      unless space.admins.empty?
        jid = Jabber::JID.new(space.admins[0].username.to_s + presence_domain.to_s)
        client = Jabber::Client.new(jid)
        client.connect
        client.auth(space.admins[0].encrypted_password)
        conference = presence_domain.to_s
        conference = conference.gsub('@', "@conference.")
        muc = Jabber::MUC::MUCClient.new(client)
        puts "* Space name: " + space.name + " -- " + space.admins[0].full_name
        muc.join(space.permalink + conference + "/" + client.jid.node, "newpassword")
        muc.configure({
                        'muc#roomconfig_roomname' => space.name,
                        'muc#roomconfig_passwordprotectedroom' => 1,
                        'muc#roomconfig_roomsecret' => 'newpassword',
                        'muc#roomconfig_roomdesc' => space.description,
                        'muc#roomconfig_persistentroom' => 1
                      })
        muc.exit
        client.close
      end
    end
    puts "It's over! All rooms created!!"
  end
end
