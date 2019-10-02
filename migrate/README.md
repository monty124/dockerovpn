# migrate scripts

The hell is this shit?

so the docker gui in synology is terribly limited and I hate logging into ssh just to do simple tasks
these scripts allow you to convert synology docker config exports into either a command line block for use withthe docker cli
or a yml (vomit) file to be used with docker-compose

no warranty use at your own risk!

syno2docker.ps1 - spits out a docker cli command 

syno2docker-compose.ps1 - spits out a docker-compose yml using the same base name as the json file

Usage: 

How do I get started?

1. run the powershell script

2. ??

3. do the needful

4. profit

How is this useful?

well, run the docker-compose guy and spit out a yml

delete your existing docker machine (they are not compatible)

run something like this to re-create

docker-compose -f (yml file) up -d --force-recreate

ignore these errors:

WARNING: Found orphan containers (xxxx) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.

(i'll get to looking at this and finding a work around eventually!) maybe

then when the image is updated run the same command from say a disabled scheduled task!

BINGO!


could the script be tidier or more efficient? could the yml compose files be better handled? 

Yeah probably, do a fork then submit a PR if you think you can improve!

