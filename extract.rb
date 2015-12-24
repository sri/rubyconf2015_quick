#! /usr/bin/env ruby
# Quick & dirty script to get the raw data.
# Downloads resources so that hitting the
# servers are minimized while running small
# experiments to extract the data.

require 'open-uri'
require 'json'

url = 'http://confreaks.tv/events/rubyconf2015'
name = File.basename(url)
unless File.exists?(name)
  puts "downloading #{url}..."
  open(name, "w") { |f| f.write open(url).read }
end

html = File.read(name)
urls = html.scan(/\/videos[^"]*/).sort.uniq.reject { |u| u =~ /Capture-thumb/ }
urls.each do |url|
  name = File.basename(url)
  next if File.exists?("video/#{name}")
  puts "downloading #{url} to #{name}"
  open("video/#{name}", "w") { |f| f.write open("http://confreaks.tv#{url}").read }
end

youtube_urls = Dir['video/*'].map do |f|
  html = File.read(f)
  [f, html.scan(/\/\/youtube[^"]+/)].flatten
end
youtube_urls.each do |name, url|
  name = "youtube/#{name}"
  next if File.exists?(name)
  puts "downloading #{url}..."
  open(name, "w") { |f| f.write open("https:#{url}").read }
end

h = {}
youtube_urls.each do |name, url|
  html = File.read("youtube/#{name}")
  h[url] = html.scan(/length_seconds":([0-9]+)/).flatten.first.to_i
end
open("rubyconf2015.json", "w") { |f| f.write JSON.generate(h) }
