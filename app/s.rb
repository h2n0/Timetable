
#!/usr/bin/ruby
require "sinatra"
require_relative "int/parse.rb"

get "/" do
	erb :index
end

get "/user/:id" do
	n = params["id"]
	hour = Time.new.hour
	s = Student.fromNumber(n)
	f = Nokogiri::HTML(open("int/timetable"))
	t = Timetable.new(f)

	if s == nil
		erb :index, :locals => {:err => "No data on that user"}
	else
		t.getToday()
		erb :user, :locals => {:id => n, :hour => hour, :lecs => t.getLectures(s)}
	end
end

get "/error" do
	puts "This is the error page"
	puts "Check back soon"
end
