require "octokit"
require_relative "info.rb"
client = Octokit::Client.new(:login => Config.getUser(), :password => Config.getPass())

g = nil

client.gists().each do |x|
	if x.description == "Timetable simplifier"
		g = x		
	end
end

if g == nil
	puts "Unable to find gist!"
else
	t = Time.now
	res = ""
	g.files.each do |f|
		res += "#{f[1][:raw_url]}\n"
	end
	File.open("dl.txt","w"){|dl| dl.write(res)}
end
