import getpass
import sys
import settings

name = ""
pasw = ""

update = sys.argv[1] == "update"

if update:
	name = settings.USER
	pasw = settings.PASS
else:
	name = raw_input("Username: ")


def genCMD(name, pasw):
	res = "# {}\nkey A\nkey ^J\nkey Down Arrow\nkey Down Arrow\nkey Down Arrow\nkey Down Arrow\nkey Down Arrow\nkey Up Arrow\n".format(name)
	for i in range(0, len(name)):
		res += "key {}\n".format(name[i])
	res += "key Down Arrow\n"
	for i in range(0, len(pasw)):
		res += "key {}\n".format(pasw[i])
	res+="key Down Arrow\nkey Down Arrow\nkey ^J\nkey Down Arrow\nkey Down Arrow\nkey Down Arrow\nkey Down Arrow\nkey Down Arrow\nkey ^J\nkey \ \nkey p\nkey ^J\nkey ^J\nkey y\nkey q\nkey y"
	return res



file = open("test.txt","w")
if update:
	file.write(genCMD(name,pasw))
else:
	file.write("#{}".format(name))
file.close()

