
ruby check.rb
FILES=$(cat dl.txt)
cd int
rm cmd.py
rm *.pyc
rm *.sh
rm *.rb
rm *.[0-9]
wget $FILES
chmod +x ./t.sh
cd ../
rm dl.txt
