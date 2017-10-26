require "nokogiri"
require "date"


=begin
	TODO
	-Weird edge cases on a tuesday
=end

class Student

	# Default constructor for Student
	# @param lastname [String] the last name of the student
	# @param group [Int] the last name of the student
	# @param seminarGroup [String] the seminar group
	# @param number [Int] the students ID
	# @param lastID [Int] the last number of the students ID
	def initialize(lastName, group, seminarGroup, number, lastID)
		@ln = lastName
		@gr = group
		@sg = seminarGroup
		@pg = findGroup(@ln)
		@id = number
		@li = lastID
	end
	
	# Construct Student from a string
	# @param parts [String] "ID LASTNAME CS-110 CS-130"
	def self.fromArgs(parts=ARGV[0].strip.split(" "))
		id = parts[0].strip #Student ID
		lastName = ""
		group = 0
		seminarGroup = 0
		practicalGroup = "Z"
	
		if(parts.length > 4) # Weird name formatting again
			lastName = ""
			d = (parts.length-4)
			for i in 0..d
				lastName = lastName + parts[1 + i].strip + " "
			end
		
			lastName.strip!
			group = parts[d + 2].strip.to_i #CS-110 Lab group
			seminarGroup = parts[d + 3].strip.to_i #CS-130 Seminar
		else
			lastName = parts[1].strip
			group = parts[2].strip.to_i #CS-110 Lab group
			seminarGroup = parts[3].strip.to_i #CS-130 Seminar
		end
		lastID = id[-1].to_i
		return Student.new(lastName, group, seminarGroup, id, lastID)
	end
	
	# Construct all students in a pre-defined file
	# @return [Student[]] sorted by ID
	def self.loadAll()
		res = []
		File.open("int/aloc2.txt").each do |line|
			res.push(fromNumber(line.split(" ")[0]))
		end
		return res.sort!{|s1,s2| s1.getID() <=> s2.getID()}
	end
	
	# Get a student just from their ID
	# @param id [Int] the ID of the student we're after
	def self.fromNumber(id)
		File.open("int/aloc2.txt").each do |line|
			p = line.split(" ")
			if p[0] == "#{id}"
				return fromArgs(p)
			end
		end
		
		puts "Couldn't find that ID"
		return nil
	end
	
	# Return the last name of the student
	# @return [String]
	def getName()
		return @ln
	end
	
	# Return the group for CS-110 the student is in
	# @return [Int]
	def getGroup()
		return @gr
	end
	
	# Return the CS-130 seminar group of the student
	# @return [Int]
	def getSeminar()
		return @sg
	end
	
	# Return the CS-130 practical group of the student
	# @return [String]
	def getPractical()
		return @pg
	end
	
	# Return the ID of the student
	# @return [Int]
	def getID()
		return @id
	end
	
	# Return the last digit in the student's ID
	# @return [Int]
	def getLastID()
		return @li
	end
	
	private
	def findGroup(ln)
		ar = ["Abajingin", ln, "Debiciki"].each{|l| l.downcase!}.sort!
		if(ar[1] == ln)
			return "A"
		end
	
		ar = ["Debreczeny", ln, "Jones"].each{|l| l.downcase!}.sort!
		if(ar[1] == ln)
			return "B"
		end
	
		ar = ["Kankol", ln, "Mosphilis"].each{|l| l.downcase!}.sort!
		if(ar[1] == ln)
			return "C"
		end
	
		ar = ["Mounter", ln, "Sailes"].each{|l| l.downcase!}.sort!
		if(ar[1] == ln)
			return "D"
		end
	
		ar = ["Salamanca", ln, "Zakarian"].each{|l| l.downcase!}.sort!
		if(ar[1] == ln)
			return "E"
		end
	end

end

class Lecture
	
	# Contructor for the Lecture object
	# @param name [String] the title of the lecture
	# @param day [Int] the day of the week the lecture is on
	# @param sta [Int] the hour that the lecture starts
	# @param len [Int] the length of the lecture
	# @param loc [String] the location of the lecture
	# @param date [DateTime] the DateTime of the lecture
	def initialize(name,day,sta,len,loc, date)
		@name = name.split(" ")[0]
		@day = day
		@sta = sta
		@len = len
		@loc = loc
		@date = date
	end

	# @return [Int] the hour the lecture starts
	def getStart()
		return @sta
	end

	# @return [Int] the length of the lecture
	def getLength()
		return @len
	end
	
	# @return [Int] the hour the lecture ends
	def getEnd()
		return @sta + @len
	end
	
	# @return [DateTime]
	def getDateTime()
		return @date
	end
	
	# @return [Int] the day of the week the lecture is on
	# @note 0 = Monday
	# @note 6 = Sunday
	def getDay()
		return @day
	end

	# @return [String] the name of the lecture
	def getName()
		return @name
	end
	
	# @return [String] the location of the lecture
	def getLocation()
		return @loc
	end

	# @return [String] the details in a user frindly format
	# @example 
	#		CS-110 - 11 - 13 - Talbot 043
	def to_s()
		return "#{@name} - #{@sta} - #{getEnd()} - #{@loc}"
	end
	
	# Get a JSON string of the object
	# @return [String/JSON]
	# @example
	#		{
	#			name => "CS-110",
	#			start => 11,
	#			length => 2,
	#			location => "Talbot 043"
	#		}
	def to_json(*a)
		return {:name => @name, :start => @sta, :location => @loc, :length => @len}.to_json(*a)
	end

end

class Timetable

	@lectures = []
	@secific = []
	@td = 0
	
	# Default constructor of Timetable
	# @param timetable [Nokogiri::HTML]
	# @see http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/HTML HTML
	def initialize(timetable)
		divs = timetable.css("div.slot")
		lectures = []

		divs.each do |d|
			if(d.children.length > 0)

				day = d["data-day"].to_i
				hour = d["data-hour"].to_i
				
				dateDay = d["data-day-of-month"].to_i
				dateMonth = d["data-month"].to_i
				dateYear = d["data-year"].to_i
				d.children.each do |s|
					t = "#{s['class']}".strip
					if(t != "lecture")
						next
					end
			

					vals = []
					s.children.each do |l|
						if(l.class == Nokogiri::XML::Text)
							next
						end
						vals.push(l.children[0])
					end

					name = "#{vals[0]}"
					name = name.split(" ")[0]
					where = ""
					length = 1

					if(vals.length == 3)
						length = "#{vals[1]}".split(" ")[0].to_i
						where = vals[2]
					elsif vals.length == 4
						where = vals[3]
					elsif vals.length == 2
						where = vals[1]
					end
					date = DateTime.new(dateYear, dateMonth, dateDay, hour)
					lectures.push(Lecture.new(name, day, hour, length, "#{where}", date))
				end
			end
		end
		
		@lectures = lectures
		doubleCheck()
	end
	
	# Get the day name for the given day
	# @param day [Int] 0 -> 6
	# @return [String] the name of the day
	def getDayName(day=@td)
		days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
		return days[day]
	end
	
	# Get all of the lectures for the current day
	def getToday()
		getDay(Time.new.wday - 1)
	end
	
	# Get al the lectures of a given day
	def getDay(td)
		tdls = @lectures.select{|l| l.getDay() == td}
		@td = td
		@specific = tdls
	end
	
	
	def getDaysLectures(s,td)
		getDay(td)
		return getLectures(s)
	end
	
	# Get all of the lectures that meet the requiments
	# @param s [Student] a valid student
	# @param td [Int] the day of the week
	# @param p [Boolean] should we print results
	# @return [Lecture[]]
	def getLectures(s,td=@td,p=false)
		res = []
		getDay(td)
		
		if p
			puts "--- #{getDayName(td)} ---"
		end
		if @specific.length > 0
			@specific.each do |l|
			if(td == 0) # Monday
				if(l.getName() == "CS-110")
					if(s.getGroup() == 2 && l.getStart() == 12)
						next
					end
				end
			elsif(td == 1) # Tuesday
				if(l.getName() == "CS-110")
					if(s.getGroup() == 3)
						next
					end
				
				
					if s.getGroup() == 2 && (l.getStart < 11 || l.getEnd > 13)
						next
					end
				
					if(s.getGroup() == 1 && l.getEnd > 10)
						next
					end
				elsif(l.getName() == "CS-130")
					if(s.getSeminar() == 5)
						next
					end
			
					if(l.getStart() >= 9 && l.getEnd() <= 13)
						if(s.getSeminar() == 1 && l.getStart() != 9)
							next
						elsif(s.getSeminar() == 2 && l.getStart() != 10)
							next
						elsif(s.getSeminar() == 3 && l.getStart() != 11)
							next
						elsif(s.getSeminar() == 4 && l.getStart() != 12)
							next
						end
					end
				
					if(s.getPractical() == "D" || s.getPractical() == "E")
						next
					end
				
					if s.getPractical() == "C" && l.getLocation().include?("043")
						next
					end
				
					if s.getPractical() != "C" && !l.getLocation().include?("043")
						next
					end
				end
			elsif(td == 2) # Wednesday
				if(l.getName() == "CS-170")
					if(s.getLastID() % 2 == 1 && l.getStart() == 10)
						next
					end
			
					if(s.getLastID() % 2 == 0 && l.getStart() == 11)
						next
					end
			
					loc = l.getLocation()
					if(loc.include?("B") || loc.include?("D"))
						if(s.getLastID() > 1)
							next
						end
					elsif(loc.include?("38"))
						if(s.getLastID() > 3 || s.getLastID() < 2)
							next
						end
					elsif(loc.include?("314"))
						if(s.getLastID() > 5 || s.getLastID() < 4)
							next
						end
					elsif(loc.include?("45"))
						if(s.getLastID() > 7 || s.getLastID() < 6)
							next
						end
					elsif(loc.include?("47"))
						if(s.getLastID() > 9 || s.getLastID() < 8)
							next
						end
					end
				end
			elsif (td == 3) # Thursday
				if(l.getName() == "CS-130")
					if(s.getSeminar() != 5 && l.getStart() == 9)
						next
					end
			
					if (s.getPractical() != "D" || s.getPractical() != "E") && (l.getStart() == 16 || l.getStart == 17)
						next
					end
				end
			elsif(td == 4) #Friday
				if(l.getName() == "CS-110")
					if(s.getGroup() < 2)
						next
					end
			
					if(s.getGroup() == 2 && l.getLength() != 1) #In group 2 and the lecture is 2 hours long
						next
					end
					if(s.getGroup() == 3 && l.getLength() != 2) #In group 3 and the lecture is 1 hour long
						next
					end
				end
			end
			res.push(l)
			end
		end
		return res
	end
	
	private
	def doubleCheck()
		puts @lectures
		getDay(1)
		rem = [] #Elements we need to remove
		for i in 0..@specific.length-2
			cl = @specific[i]
			nl = @specific[i+1]
			
			#puts cl.getLength()
			#puts nl.getLength()
		end
		puts rem
	end
end
