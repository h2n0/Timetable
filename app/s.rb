#!/usr/bin/ruby
require "sinatra"
require_relative "int/parse.rb"

get "/" do
	erb :index
end

get "/user/:id/:tom?" do
	n = params["id"]
	hour = Time.new.hour
	s = Student.fromNumber(n)
	f = Nokogiri::HTML(open("int/timetable"))
	t = Timetable.new(f)

	if s == nil
#		erb :index, :locals => {:err => "No data on that user"}
	else
		if params["tom"] == "tomorrow"
			t.getDay(Time.new.wday)
			hour = 8
		else
			t.getToday()
		end
		erb :user, :locals => {:id => n, :hour => hour, :lecs => t.getLectures(s)}
	end
end

get "/error" do
	puts "This is the error page"
	puts "Check back soon"
end
