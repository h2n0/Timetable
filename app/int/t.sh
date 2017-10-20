python cmd.py "$1"
if [ "$1" == "update" ]; then
	lynx --cmd_script=test.txt "https://science.swansea.ac.uk" > /dev/null
	rm test.txt
	exit 0
fi


## Older code that still kind works
ID=$(cat test.txt | head -1 | tail -1 | tr -d "# ")
if [ "$ID" == "" ]; then
	echo "No ID given"
	exit 1
fi
G=$(cat aloc2.txt | grep -c -w "$ID")

if [ $G == 0 ]; then
	echo "Couldn't find the user with that ID"
	exit 1
fi

G=$(cat aloc2.txt | grep -w "$ID")
ruby parse.rb "$G"

