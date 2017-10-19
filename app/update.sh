
ruby check.rb

if [ $? != 0 ]; then
	echo "Somthing went wrong!"
	exit 1
fi
FILES=$(cat dl.txt)

if [ ! -d "int" ]; then
	mkdir int
	cd int
else
	cd int
fi
rm cmd.py
rm *.pyc
rm *.sh
rm *.rb
rm *.[0-9]
wget $FILES
chmod +x ./t.sh
cd ../
rm dl.txt
