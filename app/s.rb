#!/usr/bin/ruby
require "sinatra"
require_relative "int/parse.rb"
require_relative "int/logger.rb"

f = Nokogiri::HTML(open("int/timetable"))
t = Timetable.new(f)
log = Logger.new("public/logs/")

get "/" do
	erb :index
end

get "/user/:id/:tom?" do
	n = params["id"]
	hour = Time.now.hour
	s = Student.fromNumber(n)

	if s == nil
		erb :index, :locals => {:err => "No data on that user"}
	else
		if params["tom"] == "tomorrow"
			t.getDay(Time.now.wday)
			hour = 8
		else
			t.getToday()
		end
		erb :user, :locals => {:id => n, :hour => hour, :lecs => t.getLectures(s)}
	end
end

post "/error" do
	name = params["name"]
	id = params["id"]
	dets = params["dets"]
	t = Time.now
	n = "#{t.year}-#{t.month}-#{t.day}-#{t.hour}#{t.min}#{t.sec}"
	File.open("public/feedback/#{n}.txt", "w") do |f|
		f.write("Name: #{name}\n")
		f.write("ID: #{id}\n")
		f.write("Details: #{dets}")
	end
	
	erb :error, :locals => {:done => true}
end

get "/error" do
	erb :error
end
