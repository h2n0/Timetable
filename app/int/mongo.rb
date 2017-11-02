require "mongo"

# Just so the output dosen't fill up
Mongo::Logger.logger.level = ::Logger::FATAL

def getUser(id)
	db = connect()
	res = db[:users].find("id" => id)
	return res
end

def addUser(id, name)
	
end

private
def connect
	db = Mongo::Client.new(["localhost:27017"], :database => "plaintime")
	return db
end
