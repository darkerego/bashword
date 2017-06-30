#!/bin/bash
####################################################
echo "╔╗ ╔═╗╔═╗╦ ╦╦ ╦╔═╗╦═╗╔╦╗";
echo "╠╩╗╠═╣╚═╗╠═╣║║║║ ║╠╦╝ ║║";
echo "╚═╝╩ ╩╚═╝╩ ╩╚╩╝╚═╝╩╚══╩╝";      
echo "Bash powered password manager ~ Darkerego 2017";
####################################################
#

# This stuff is over-written by the variables in ~/.bashword/bashword.conf
# A base64 encoded raw gpg message. set this first. use `gpg -c|base64`
# when you generate a new password, first the script prompts you for your
# master password and makes sure it can decrypt this string first before 
# continueing, because all passwords in the database need to be encrypted
# with the same password for this to work correctly.

# example password "lol"
user_str='jA0EAwMCCex3BqkGDYNgySZto07doXdk2uyaSI/sl6OB0mPQQIsdGe0MNv1op8xXAP9BR639Lw=='
# also we can limit this to a certain user id
user_id=1000



genconf(){
conffile=~/.bashword/bashword.conf
read -rp "Enter a unique string to be encrypted with your passphrase. This string must be decrypted every time you generate a new password or decrypt your database : " myKey
cd $HOME
rm -f $userkey $userkey.gpg
echo "$myKey" > userkey

gpg --no-use-agent -c  userkey >userkey.gpg
test -s userkey.gpg || { echo error ; exit 1 ;}
_user_str=$(base64 -w 0 userkey.gpg)
echo "Your unique user string : "
echo "$_user_str"
{ echo "user_str=$_user_str">$conffile ; echo "user_id=$(id -u)">>$conffile ;}

if [[ "$?" -eq "0" ]] ;then
  echo "Your config file has been created succesfully"
else
  echo 'Some error. Quitting!'
   exit 1
fi
}

usage(){
echo -e "#####################################
# Bashword (Version 2.0 Beta)
# A Password Manager Written in Bash 
#####################################
# USAGE: $0 -n/-d

# Generate a New Password:
  [$0 <-g\--gen> <length>]

# Decrypt and Open Passwords:
  [$0 <-d\--decrypt\-o\--open>]

# REQUIRES:
  gpg, base64, bash, echo (with -en)"
}

genPW(){
set +a # dont export variables
if [[ $len = *[^0-9]* ]];
  then
   echo " ";
   echo "      ######### COMMAND FAILED ########## ";
   echo "      USAGE: $0 -g passwordlength";
   echo "      EXAMPLE: Creates a random password 10 chars long.";
   echo "        $0 -g 10                ";
   echo "        The password is than gpgd and appended to ~/.encpass ";
   echo "      EXAMPLE: Decrypt password database:";
   echo "        $0 -d";
   echo "      ######### COMMAND FAILED ########## ";
   echo " ";
   exit
  else
   if [[ "$len" -lt "6" ]]
   then echo "Your password is less than 6 characters in length."
         echo "This is a security risk. Suggested length is 6 characters or longer !"
   fi
   
   
   RIGHTNOW=$(date +"%R %x")
   pwdlen=$len
   char=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V X W Y Z _ - + % '_' '.' '^' '!' '`' '~' '#' '&' '_' '(' ')' '|' '{' '}' '[' ']' '\' '<' '>' '=' ',' ':' '?')
   max=${#char[*]}
   for i in `seq 1 $pwdlen`
      do
           let "rand=$RANDOM % 93"
      str="${str}${char[$rand]}"
      done
   echo "#### Your password: ####"
   echo "$str"
fi
echo 'Enter a password description :'
read -r pwinfo

#test -e ~/.encpass||>~/.encpass

# TODO: maybe use openssl instead... (openssl enc -aes-256-cbc -salt -in - -out -)

#_now="$(date +%s)"
read -rsp "Enter your passphrase : " user_pw
echo -n "$user_str"|base64 -d | gpg --no-use-agent -d --passphrase "$user_pw" >/dev/null 2>&1 ||\
  { echo 'Bad key or user_str not configured' && exit 1 ;}

tempf="$(mktemp -p /home/$USER/.bashword bashwdtmp.XXXXXX.$$)"
echo $RIGHTNOW : $pwinfo : $str | gpg -ac  --passphrase "$user_pw" --no-use-agent >$tempf 2>/dev/null || { echo "Bad key!";exit 1 ;}
echo "$(base64 -w 0 $tempf)" >> $bwdb
echo
echo 'Output saved to passwords file'
srm $tempf >/dev/null 2>&1||rm -f $tempf
}

decrypt(){
set +a # dont export variables




read -rsp "Enter your passphrase : " user_pw
echo -n "$user_str"|base64 -d | gpg --no-use-agent -d --passphrase "$user_pw" >/dev/null 2>&1 ||\
  { echo 'Bad key or user_str not configured' && exit 1 ;}

echo
echo '------------------------------------------------'

data_base="$bwdb"
while IFS= read -r line
do
  printf '%s\n' "$line"|base64 -d|gpg --no-use-agent -d --passphrase "$user_pw" >/dev/stdout 2>/dev/null
done <"$data_base"

echo '-----------------------------------------------'

read -rsp "Press enter to reset the console..." clear_term
reset >/dev/null 2>&1 || clear
}





_now="$(date +%s)"
if [ "$(id -u)" != "$user_id" ]; then
   echo "Wrong user!" 1>&2
   exit 1
fi

test -d ~/.bashword || mkdir ~/.bashword
bwdb="/home/$USER/.bashword/.encpass"
bwconf="/home/$USER/.bashword/bashword.conf"
test -e $bwdb||>$bwdb
chmod 700 ~/.bashword >/dev/null 2>&1
chmod 600 "$bwconf" >/dev/null 2>&1



if [[ -f "$bwconf"  ]];then 
  echo "Found $bwconf , importing your configuration..." 
  . "$bwconf"

else
  read -rp 'No config file found, would you like to create one now? (yes/no) : ' create_conf
  if [[ "$create_conf" == "yes" ]] ; then
    genconf
  else
    echo 'Running anyway. Please rerun and create a config to supress this error.'
    echo "Example key is 'lol' "
  fi
fi

case $1 in
-g|--gen|--generate)
len=$2
genPW $len
;;
-d|--decrypt|-o|--open)
decrypt
;;
-h|--help)
usage
;;
esac
exit
