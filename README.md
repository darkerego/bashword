# bashword
====================
## A Bash-Powered Password Manager


### Usage:


- First run: create a config file

<pre>
anon@dev:~$ bash bashword.bash -g 10
╔╗ ╔═╗╔═╗╦ ╦╦ ╦╔═╗╦═╗╔╦╗
╠╩╗╠═╣╚═╗╠═╣║║║║ ║╠╦╝ ║║
╚═╝╩ ╩╚═╝╩ ╩╚╩╝╚═╝╩╚══╩╝
Bash powered password manager ~ Darkerego 2017
No config file found, would you like to create one now? (yes/no)yes
Enter a unique string to be encrypted with your passphrase. This string must be decrypted every time you generate a new password or decrypt your database.This is my string!
File `userkey.gpg' exists. Overwrite? (y/N) y
Your unique user string : 
jA0EAwMCFSAVo0XOPylgyS6t3pHAVbhvYx7w7YfA2jWxrcltfW4dlttCuLSKvTGxqTKrr8/2EkXKAqNNqHVm
Your config file has been created succesfully
#### Your password: ####
>tQ88QWXE\
Enter a password description :
this is my first password
Enter your passphrase : 
Output saved to passwords file
anon@dev:~$ bash bashword.bash -d
╔╗ ╔═╗╔═╗╦ ╦╦ ╦╔═╗╦═╗╔╦╗
╠╩╗╠═╣╚═╗╠═╣║║║║ ║╠╦╝ ║║
╚═╝╩ ╩╚═╝╩ ╩╚╩╝╚═╝╩╚══╩╝
Bash powered password manager ~ Darkerego 2017
Found /home/anon/.bashword/bashword.conf , importing your configuration...
Enter your passphrase : 
------------------------------------------------
18:14 06/30/2017 : this is my first password : >tQ88QWXE\
-----------------------------------------------
Press enter to reset the console...

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
