apt-get update > /dev/null
apt-get upgrade > /dev/null

# Really, really need this one
apt-get install ruby > /dev/null
if [ $? != 0 ]; then
	echo "Failed to install ruby"
	exit 1
fi

# Needed to get an updated timetable
apt-get install lynx > /dev/null
if [ $? != 0 ]; then
	echo "Unable to install Lynx browser"
	exit 1
fi

# Needed for Nokogiri
apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev > /dev/null
#
if [ $? != 0 ]; then
	echo "Failed to install Nokogiri essentals"
	exit 1
fi

# Setup all of the gems needed to run the server
gem install bundler
if [ $? != 0 ]; then
	echo "Failed to install bundler"
	exit 1
fi

bundler install
if [ $? != 0 ]; then
	echo "Failed to install required gems"
	exit 1
fi
