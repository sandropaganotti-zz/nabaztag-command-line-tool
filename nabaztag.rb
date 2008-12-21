#!/opt/local/bin/ruby

require 'rubygems'
require 'scrubyt'

TOKEN = "your nabaztag token" 
SN = "your nabaztag serial number"

command, params = ARGV[0], ARGV[1..-1]

if command.nil? or command == 'help'
puts <<-EOS; exit 

Nabaztag command line, usage: nabaztag.rb command [params]
Where commands can be:
  
  playlist    Load a playlist from playlist.com inside your nabaztag and
              starts playing, example: nabaztag.rb playlist 3041414155
              You may find the playlist number inside the playlist URL.
              
  help        You're looking it :)

EOS
end


case command

  # playlist 
  when 'playlist'
      playlist = Scrubyt::Extractor.define do
          fetch "http://view.playlist.com/#{params[0]}/asx"
          ele "//entry//ref" do
            mp3 "href", :type=>:attribute
          end
      end.to_hash.collect{ |e| e[:mp3]}
      
      puts "I'm ready to send #{playlist.size} songs to your nabaztag, do you agree (Y/n) ?"
      answer = STDIN.gets
      exit if answer == 'n'
      puts "Ok, sending.."
      
      result = Scrubyt::Extractor.define do  
          fetch "http://api.nabaztag.com/vl/FR/api_stream.jsp?token=#{TOKEN}&sn=#{SN}&urlList=#{playlist.join("|")}"
          message "//message"
          comment "//comment"
      end.to_hash
      puts "Your rabbit says: #{result[1][:comment]}"
      
  else
    puts "Command #{command} not understood; type nabaztag.rb help for a list of available commands"

end


