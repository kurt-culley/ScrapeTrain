require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'open-uri'

artist_url = ARGV[0].to_s

artist_page = HTTParty.get(artist_url)
parsed_artist_page = Nokogiri::HTML(artist_page)

artist_name = parsed_artist_page.css('div#track-header span').text

track_list = parsed_artist_page.css('table')
track_array = []
track_list.xpath('//tr[starts-with(@id, "track-row")]').each do |tr|
  track_array << tr
end

track_id_array = []
track_array.each do |track|
  track_id_array << track.css('a').attr('id').value
end

track_list = []
track_id_array.each do |id|
  track_link = HTTParty.get("http://traktrain.com/scripts-v2/selectTrack.php?track=#{id}")
  track_link_parsed = JSON.parse(track_link)
  track_list << {'name' => "#{track_link_parsed["trackName"]}",
   'link'=> "http://traktrain.com/scripts-v2/stream.php?track=#{track_link_parsed["trackLink"]}"}
end

puts "[BEGIN] Artist: #{artist_name} Track count: #{track_list.count}"

puts "[INFO] Creating directory #{artist_name} if it does not already exist"
Dir.mkdir("#{artist_name}") unless File.exists?("#{artist_name}")

track_list.each do |track|
  puts "[INFO] Downloading: #{track["name"]}.mp3"
  open("#{artist_name}/""#{track["name"]}.mp3", 'wb') do |f|
    f << open("#{track["link"]}", "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0").read
  end
  puts "[INFO] Complete: #{track["name"]}.mp3"
end

puts "[DONE]"
