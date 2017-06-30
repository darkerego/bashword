# bashword
====================
## A Bash-Powered Password Manager


### Usage:


- Set your $user_str variable near top of script:

<pre>
echo "this is my key" > userkey
gpg -c userkey >userkey.gpg
user_str=$(base64 -w 0 userkey.gpg)
echo "this is your user string:"
echo $user_str # place this in the user_str variable in script
</pre>

- Generate a password and save to encrypted file

<pre>
anon@dev:~/Dev$ bash ./bashword -g 12
#### Your password: ####
o>}{A#lo1c1y
Enter a password description
testing this script
Enter your passphrase: 
Output saved to passwords file
</pre>

- Decrypt passwords stored in ~/.encpass

<pre>
anon@dev:~/Dev$ bash bashword -d
Enter your passphrase : 
------------------------------------------------
17:14 06/29/2017 : testing this script : o>}{A#lo1c1y
17:14 06/29/2017 : test : u4[l(NXRVW
17:15 06/29/2017 : whatever account : u=]wE<c_f
17:16 06/29/2017 : whatever other acct : QaB^)s7xj
</pre>

### Note : this is a POC , do not use in production without caution
