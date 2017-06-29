#!/bin/bash
####################################################
echo "╔╗ ╔═╗╔═╗╦ ╦╦ ╦╔═╗╦═╗╔╦╗";
echo "╠╩╗╠═╣╚═╗╠═╣║║║║ ║╠╦╝ ║║";
echo "╚═╝╩ ╩╚═╝╩ ╩╚╩╝╚═╝╩╚══╩╝";      
echo "Bash powered password manager ~ Darkerego 2017";
####################################################
#

# a base64 encoded raw gpg message. set this first. use `gpg -c|base64`
# when you generate a new password, first the script prompts you for your
# master password and makes sure it can decrypt this strings first before 
# continueing, because all passwords in the database need to be encrypted
# with the same password for this to work correctly.

user_str='jA0EAwMCCex3BqkGDYNgySZto07doXdk2uyaSI/sl6OB0mPQQIsdGe0MNv1op8xXAP9BR639Lw=='

# also we can limit this to a certain user id
user_id=1000
_now="$(date +%s)"
if [ "$(id -u)" != "$user_id" ]; then
   echo "Wrong user!" 1>&2
   exit 1
fi

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
   char=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V X W Y Z _ - + % '$' '.' '^' '!' '`' '~' '#' '&' '*' '(' ')' '|' '{' '}' '[' ']' '\' '<' '>' '=' ',' ':' '?')
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

if [[ ! -e ~/.encpass ]]
then 
   >~/.encpass
fi
# TODO: maybe use openssl instead... (openssl enc -aes-128-cbc -salt -in .tmpmaster -out .bastword-master;srm .tmpmaster)

#_now="$(date +%s)"
read -rsp "Enter your passphrase" user_pw
echo -n "$user_str"|base64 -d | gpg --no-use-agent -d --passphrase "$user_pw" >/dev/null 2>&1 ||\
  { echo 'Bad key or user_str not configured' && exit 1 ;}

tempf=/tmp/pass.tmp
echo $RIGHTNOW : $pwinfo : $str | gpg -ac  --passphrase "$user_pw" --no-use-agent >$tempf 2>/dev/null || { echo "Bad key!";exit 1 ;}
echo "$(base64 -w 0 $tempf)" >> ~/.encpass
echo
echo 'Output saved to passwords file'
srm $tempf >/dev/null 2>&1||rm -f $tempf
}

decrypt(){
set +a # dont export variables
read -rsp "Enter your passphrase : " user_pw
echo
echo '------------------------------------------------'
for i in $(cat ~/.encpass); do echo "$i"|base64 -d|gpg --no-use-agent -d --passphrase "$user_pw" >/dev/stdout 2>/dev/null ;done
echo '-----------------------------------------------'
}

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
