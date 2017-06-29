#!/bin/bash
####################################################
# BASH Password Manager - Darkerego 2017
####################################################
#


user_str='jA0EAwMCCex3BqkGDYNgySZto07doXdk2uyaSI/sl6OB0mPQQIsdGe0MNv1op8xXAP9BR639Lw=='
if [ "$(id -u)" != "1000" ]; then
   echo "Wrong user!" 1>&2
   exit 1
fi

usage(){
echo -e "#Bastword (Version 1.0 Alpha)#
# A Password Manager Written in Bash #
# USAGE: $0 -n/-d
Generate a New Password:
[$0 <-n\--new\-g\--gen> <length>]
Decrypt and Open Passwords:
[$0 <-d\--decrypt\-o\--open>]
# REQUIRES:
gpg, base64, secure-delete, bash"
}

genPW(){

#if [[ -z "$2" || $2 = *[^0-9]* ]];
if [[ $len = *[^0-9]* ]];
  then
   echo " ";
   echo "      ######### COMMAND FAILED ########## ";
   echo "      USAGE: $0 passwordlength";
   echo "      EXAMPLE: $0 10";
   echo "      Creates a random password 10 chars long.";
   echo "      ######### COMMAND FAILED ########## ";echo " ";
   exit
  else
   if [[ "$len" -lt "6" ]]
   then echo "Your password is less than 6 characters in length."
         echo "This is a security risk. Suggested length is 6 characters or longer !"
   fi
   
   
   RIGHTNOW=$(date +"%R %x")
   pwdlen=$len
   char=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V X W Y Z _ - + % '$' '.' '^' '!' '`' '~' '#' '&' '*' '(' ')' '|' '{' '}' '[' ']' '"' '<' '>' '=' ',' ':' '?')
   max=${#char[*]}
   for i in `seq 1 $pwdlen`
      do
           let "rand=$RANDOM % 93"
      str="${str}${char[$rand]}"
      done
   echo "#### Your password: ####"
   echo "$str"
fi
echo 'Enter a password description'
read pwinfo

if [[ ! -e ~/.encpass ]]
then 
   touch ~/.encpass
fi
# TODO: Check aespipe password against current master password to avoid accidentally encrypting different passwords with 
# the wrong password... (openssl enc -aes-128-cbc -salt -in .tmpmaster -out .bastword-master;srm .tmpmaster ;check_it())

_now="$(date +%s)"
read -rsp "Enter your passphrase" user_pw
echo -n "$user_str"|base64 -d | gpg --no-use-agent -d --passphrase "$user_pw" >/dev/null 2>&1 ||\
  { echo 'Bad key or user_str not configured' && exit 1 ;}


#echo $RIGHTNOW : $pwinfo : $str ;
# echo $user_pw 3> | gpg2 --batch --passphrase-fd 3 --armor --encrypt - >/tmp/$_now.tmp
echo $RIGHTNOW : $pwinfo : $str | gpg -ac  --passphrase "$user_pw" --no-use-agent >/tmp/$_now.tmp >/dev/null || { echo "Bad key!";exit 1 ;}
echo $(base64 -w 0 /tmp/$_now.tmp) | tee -a ~/.encpass
echo 'Output saved to passwords file'
}

decrypt(){
read -rsp "Enter your passphrase" user_pw
for i in $(cat ~/.encpass); do echo "$i"|base64 -d|gpg --no-use-agent -d --passphrase "$user_pw" >/dev/stdout 2>/dev/null ;done
}

case $1 in
-n|--new|-g|--gen|--generate)
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
