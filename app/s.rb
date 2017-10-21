#!/usr/bin/ruby
require "sinatra"
require "sinatra/cookies"
require_relative "int/parse.rb"
require_relative "int/logger.rb"

f = Nokogiri::HTML(open("int/timetable"))
t = Timetable.new(f)
log = Logger.new("public/logs/")


# Needed to keep cookies around for more than a single session
set(:cookie_options) do
  { :expires => Time.now + 3600*24*7 }
end

get "/" do
	erb :index
end

# User is sent here why the update their settings
get "/user/:id/cols/*/*/*/*" do
	parts = params["splat"]
	name = parts[0]
	
	parts[3].slice!("/")
	
	cols = cookies[:"#{name}"]
	cols = "rgb(#{parts[1]},#{parts[2]},#{parts[3]})"
	
	cookies[:"#{name}"] = cols
	
	redirect "/user/#{params['id']}/"
end

# User is looking at either today or tomorrow's timetable
get "/user/:id/:tom?" do
	n = params["id"]
	hour = Time.now.hour
	s = Student.fromNumber(n)
	colors = cookies[:colors]
	if s == nil
		log.log("Unable to find user info for ID: #{n}\n#{params}")
		erb :index, :locals => {:err => "No data on that user"}
	else
		log.log("Found info for user with ID: #{n}")
		if params["tom"] == "tomorrow"
			t.getDay(Time.now.wday)
			hour = 8
		else
			t.getToday()
		end
		
		cols = cookies.select{|k| k.start_with? "CS"}
		
		# Just to keep the cookies on the system
		if cols != nil
			cookies.each do |c|
				cookies[c[0]] = c[1]
			end
		end
		
		erb :user, :locals => {:id => n, :hour => hour, :lecs => t.getLectures(s), :colors => cols}
	end
end

# We got some feedback data
post "/feedback" do
	name = params["name"]
	id = params["id"]
	dets = params["dets"]
	ti = Time.now
	n = "#{ti.year}-#{ti.month}-#{ti.day}-#{ti.hour}:#{ti.min}:#{ti.sec}"
	File.open("public/feedback/#{n}.txt", "w") do |f|
		f.write("Name: #{name}\n")
		f.write("ID: #{id}\n")
		f.write("Details: #{dets}\n")
	end
	log.log("Feedback was posted")
	erb :error, :locals => {:done => true}
end

# User is giving us some feedback
get "/feedback/:id?" do
	erb :error, :locals => {:id => params["end"]}
end


# Simple error correction page
error 404 do
	log.err("Something wasn't found\n#{params}")
	redirect "/"
end
