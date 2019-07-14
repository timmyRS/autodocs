#!/bin/bash

clear
echo "Welcome to the autodocs setup."
echo "You're just a minute away from having your docs auto-generated."
echo ""
if [[ $(which doxygen) == "" ]]
then
	echo "It seems like you don't have doxygen installed."
	exit 1
fi
echo "First of all, make sure that"
cd $(dirname $0)
echo "$PWD"
echo "is accessible by your web server."
echo ""
cont="Once you've done that, press any key to continue."
read -p "$cont"

clear
if [[ -d rsa ]]
then
	rm -r rsa
fi
mkdir rsa
echo "You should not be able to read this via HTTP." > rsa/index.html
chmod -R 755 rsa
echo "Alright, it's good that this folder is accessible via HTTP."
echo "However, the rsa folder within this folder should not be accessible by it."
echo "If you can access it, please fix that."
echo ""
read -p "$cont"

clear
rm rsa/index.html
echo "Next, we're generating an RSA keypair for autodocs."
echo ""
email=""
while [[ "$email" == "" ]]
do
	read -p "What's the email address of your Github account? " email
done

clear
echo "Generating RSA keypair..."
ssh-keygen -t rsa -b 4096 -C "$email" -N "" -f rsa/id_rsa > /dev/null
chmod -R 700 .

while true
do
	clear
	echo "Visit https://github.com/settings/ssh/new to add this key:"
	echo ""
	cat rsa/id_rsa.pub
	echo ""
	read -p "$cont"

	clear
	echo "Authenticating against Github..."
	res=$(./ssh -T git@github.com 2>&1)
	echo ""
	echo "$res"
		echo ""
	if [[ $(echo $res | grep "successfully authenticated" -) != "" ]]
	then
		break
	fi
	read -p "That doesn't look good. Press any key to try again."
done
read -p "Looks good to me. Press any key to continue."

clear
mkdir repos
chown -R www-data:www-data .
echo "Finally, we're setting up the webhook."
echo ""
echo "Navigate to your repository on Github, go to Settings > Webhooks."
echo "Here, click the \"Add webhook\" button on the top right."
echo ""
echo "Fill out the form as follows."
echo "Payload URL: The URL at which this directory is reachable."
echo "Content type: Set to \"application/json\""
echo "Don't change anything else, and submit \"Add webhook\"."
echo ""
echo "That's it! Your docs will now be automatically generated."
