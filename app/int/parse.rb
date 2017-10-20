require "nokogiri"


=begin
	TODO
	-Weird edge cases on a tuesday
=end

class Student

	def initialize(lastName, group, seminarGroup, number, lastID)
		@ln = lastName
		@gr = group
		@sg = seminarGroup
		@pg = findGroup(@ln)
		@id = number
		@li = lastID
	end
	
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
	
	def self.loadAll()
		res = []
		File.open("int/aloc2.txt").each do |line|
			res.push(fromNumber(line.split(" ")[0]))
		end
		return res.sort!{|s1,s2| s1.getID() <=> s2.getID()}
	end
	
	def self.fromNumber(id)
		found = false
		File.open("int/aloc2.txt").each do |line|
			p = line.split(" ")
			if p[0] == "#{id}"
				return fromArgs(p)
			end
		end
		
		if !found
			puts "Couldn't find that ID"
			return nil
		end
	end
	
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

	def getName()
		return @ln
	end
	
	def getGroup()
		return @gr
	end
	
	def getSeminar()
		return @sg
	end
	
	def getPractical()
		return @pg
	end
	
	def getID()
		return @id
	end
	
	def getLastID()
		return @li
	end

end

class Lecture
	
	def initialize(name,day,sta,len,loc)
		@name = name
		@day = day
		@sta = sta
		@len = len
		@loc = loc
	end

	def getStart()
		return @sta
	end

	def getLength()
		return @len
	end

	def getEnd()
		return @sta + @len
	end
	
	def getDay()
		return @day
	end

	def getName()
		return @name
	end
	
	def getLocation()
		return @loc
	end

	def to_s()
		return "#{@name} - #{@sta} - #{getEnd()} - #{@loc}"
	end

end

class Timetable

	@lectures = []
	@secific = []
	@td = 0
	
	def initialize(timetable)
		divs = timetable.css("div.slot")
		lectures = []

		divs.each do |d|
			if(d.children.length > 0)

				day = d["data-day"].to_i
				hour = d["data-hour"].to_i
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
					where = ""
					length = 1

					if(vals.length > 3)
						length = "#{vals[2]}".split(" ")[0].to_i
						where = vals[3]
					else
						where = vals[2]
					end

					lectures.push(Lecture.new(name,day,hour,length,"#{where}"))
		#			puts "#{name} - #{length} - #{where}"
				end
			end
		end
		
		@lectures = lectures
	end
	
	def getToday()
		getDay(Time.new.wday - 1)
	end
	
	def getDay(td)
		tdls = @lectures.select{|l| l.getDay() == td}
		@td = td
		@specific = tdls
	end
	
	def getDaysLectures(s,td)
		getDay(td)
		getLectures(s)
	end
	
	def getLectures(s,td=@td,p=false)
		res = []
		getDay(td)
		
		if p
			days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
			puts "---- #{days[td]} ----"
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
end
