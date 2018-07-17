#!/bin/sh
#Include
TIMESTAMP=`date +%F-%H%M`
BACKUP_DIR_NAME="DIR_name"
BACKUP_DIR=/DIR_ADDR
DUMP_DIR=/DIR_ADDR
LOGDIR=/DIR_ADDR
RED='\033[0;31m'         #  ${RED}
GREEN='\033[0;32m'      #  ${GREEN}
BGGRAY='\033[47m'     #  ${BGGRAY}
YELLOW='\033[0;33m'     #  ${YELLOW}
NORMAL='\033[0m'      #  ${NORMAL}
BGYELLOW='\033[43m'     #  ${BGYELLOW}

#mailer


mailer()
{
FROM=mail@mail.com
TO=mail1@mail.com;mail2@mail.com
SUBJECT="Who is it?"
MIME="text/plain"  # Adjust this to the proper mime-type of file

boundary="-----------------------"

DATE=`date +"%a, %e %Y %T %z"`

( cat <<EOF
From: $FROM
To: $TO
Subject: $SUBJECT
Date: $DATE
--$boundary
Some person which login "$(date|who)"
comes to delicato server and use script "restore_local_uploads.sh"

EOF

echo "--$boundary--" ) | sendmail -t
}

checklogdir(){
if [ -d $LOGDIR ];
then
	echo "${GREEN}Log folder exist ${NORMAL}"
else
	echo "${YELLOW}You run first time? Be carefuly when use this script"
	echo "You can damage you're backup data, be attention when doin you're choise. Ty.${NORMAL}"
	mkdir $LOGDIR
	echo "${GREEN}Log folder was created ${NORMAL}"
fi
}
log(){
   message="$(date +"%y-%m-%d %T") $@"
   echo $message >>$LOGDIR/$BACKUP_NAME
}
#extractor()
#{
#tar -vxzf /dump/tmp/*.tgz
#
#}
filecheck(){
filecount=`find $BACKUP_DIR/$BACKUP_DIR_NAME -type f | wc -l`
filecountbackup=`find $DUMP_DIR/$BACKUP_DIR_NAME -type f | wc -l`
		if [ $filecount -ne $filecountbackup ];
		then
			log "${YELLOW}No files in $BACKUP_DIR_NAME ${NORMAL}"
			log "$Synchronize"
			log "$Copy start"
			else
			log "${RED}Error! Files check not passed! Files in directory ${NORMAL}"
			echo "${RED}Error! Files in directpry${NORMAL}"
			echo "Do you want to continue?"
			echo "Be carefuly! May recieve an errors y/n?"
			log "${RED}Choised copy anyway!!${NORMAL}"
			read Keypress
			case "$Keypress" in
			'y' ) cp -rv $DUMP_DIR/$BACKUP_DIR_NAME/ $BACKUP_DIR/ | tee $LOGDIR/$BACKUP_NAME
				filerecheck
				;;
			'n' ) echo "${RED} End with error "Files in docker exist" check logs in $LOGDIR${NORMAL}" && exit ;;
			esac
			
			fi
}
filerecheck(){
filecount=`find $BACKUP_DIR/$BACKUP_DIR_NAME -type f | wc -l`
filecountbackup=`find $DUMP_DIR/$BACKUP_DIR_NAME -type f | wc -l`
		if [ $filecount -ne $filecountbackup ];
		then
			log "${RED}Image data recheck not pass \"$BACKUP_DIR/\" ${NORMAL}"
			log "${RED}Whooops\! Something is going wrong. ${NORMAL}"
			recopy
			else
			echo "${GREEN}Success!!!${NORMAL}"
			fi
}
checkdockerdirr(){
		if [ -d $BACKUP_DIR/$BACKUP_DIR_NAME ];
		then
			log "${GREEN}Dir \"$BACKUP_DIR/$BACKUP_DIR_NAME\" exists ${NORMAL}"
			else
			mkdir $BACKUP_DIR/$BACKUP_DIR_NAME
			log "${GREEN}Dir \"$BACKUP_DIR/$BACKUP_DIR_NAME\" created ${NORMAL}"
			fi
}
checkdockerdirb(){
		if [ -d $BACKUP_DIR/$BACKUP_DIR_NAME ];
		then
			log "${GREEN}Dir \"$BACKUP_DIR/$BACKUP_DIR_NAME\" exists ${NORMAL}"
			else
			log "${RED}Error!! Docker backup dir was not found ${NORMAL}"
			echo "${RED}Error!! Docker backup dir was not found ${NORMAL}"
			echo "${RED}End with error check logs in $LOGDIR ${NORMAL}" && exit
			fi
}
checkdumpdir(){
		if [ -d $DUMP_DIR ]; 
		then
		log "${GREEN}Images dump folder exist"
		echo "dump folder exist use clear for clear backup"
		else
		log "${YELLOW}No such \"images\" dump folder wasn't found"
		mkdir $DUMP_DIR
		log "${GREEN}Folder \"$DUMP_DIR\" was created"
		echo "Clear not need folder is empty"
			fi
}
checkdumpdirrest(){
		if [ -d $DUMP_DIR ]; 
		then
		log "${GREEN}Images dump folder exist"
		echo "Images dump folder exist"
		else
		log "${RED}Error!! Images dump folder was not found ${NORMAL}"
			echo "${RED}Error!! Images dump folder was not found ${NORMAL}"
			echo "${RED}End with error check logs in $LOGDIR ${NORMAL}" && exit
		fi
}
recopy(){
			echo "Repeat copy operation? y/n"
			read Keypress
			case "$Keypress" in
			'y' ) cp -rv $DUMP_DIR/$BACKUP_DIR_NAME/ $BACKUP_DIR/ | tee $LOGDIR/$BACKUP_NAME;;
			'n' ) log "Error! Stopped on recopy."
				echo "Exiting..."
				echo "${RED}End with error check logs in $LOGDIR${NORMAL}"
			;;
			esac
}
restorecorefunc(){
	echo "You choise:"
	echo "restore from host to docker"
	echo "Are you sure!? y/n"
	read Keypress
	case "$Keypress" in
		'y' ) echo "continue..." ;;
		'n' ) core ;;
	esac
	APP_NAME="local_restore_uploads_to_docker"
	BACKUP_NAME="$APP_NAME-$TIMESTAMP"
	checkdockerdirr
	checkdumpdirrest
	filecheck
	cp -rv $DUMP_DIR/$BACKUP_DIR_NAME/ $BACKUP_DIR/ | tee $LOGDIR/$BACKUP_NAME
	filerecheck
	log "${GREEN}Success!!!${NORMAL}"
	echo "${GREEN}Success!!!${NORMAL}"
	core
}
backupcorefunc(){
	echo "You choise:"
	echo "backup from docker to host"
	echo "Are you sure!? y/n"
	read Keypress
	case "$Keypress" in
		'y' ) echo "continue..." ;;
		'n' ) core ;;
	esac
	APP_NAME="local_backup_uploads_from_docker"
	BACKUP_NAME="$APP_NAME-$TIMESTAMP"
	checkdockerdirb
	checkdumpdir
	echo "Clear tmp_dir? y/n"
	echo "Option clear - recreates temp folder for clear backup"
	read Keypress
	case "$Keypress" in
		'y' ) cleartmp ;;
		'n' ) log "Clear backup isn't choised, continue as is... " ;;
	esac
	cp -rv $BACKUP_DIR/$BACKUP_DIR_NAME/ $DUMP_DIR/$BACKUP_DIR_NAME/ | tee $LOGDIR/$BACKUP_NAME
	filerecheck
	log "${GREEN}Success!!!${NORMAL}"
	echo "${GREEN}Success!!!${NORMAL}"
	core
}
removetmp(){
	echo "Are you sure want to remove temp_dir!? y/n"
	read Keypress
	case "$Keypress" in
		'y' ) if [ -d $DUMP_DIR ];
			then
			echo "${GREEN}Dir \"$BACKUP_DIR/$BACKUP_DIR_NAME\" exists, removing... ${NORMAL}"
			rm -rf $DUMP_DIR
			echo "${GREEN}Image data temp storage removed \"$DUMP_DIR/\"${NORMAL}"
			echo "${GREEN}Success!!! ${NORMAL}"
			else
			echo "${GREEN}Dir \"$BACKUP_DIR/$BACKUP_DIR_NAME\" Not exist!!! ${NORMAL}"
			echo "${GREEN}Success!!! ${NORMAL}"
			fi
			;;
		'n' ) core ;;
	esac
}
cleartmp(){
	echo "Are you sure want to clear temp_dir!? y/n"
	read Keypress
	case "$Keypress" in
		'y' ) if [ -d $DUMP_DIR ];
			then
			echo "clearing..." 
			log "${GREEN}Dir \"$BACKUP_DIR/$BACKUP_DIR_NAME\" exists, clearing... ${NORMAL}"
			rm -rf $DUMP_DIR
			log "${GREEN}Image data temp storage removed \"$DUMP_DIR/\"${NORMAL}"
			mkdir $DUMP_DIR 
			log "${GREEN}Image data temp storage created \"$DUMP_DIR/\"${NORMAL}"
			echo "${GREEN}Success!!! ${NORMAL}"
			else
			log "${GREEN}Dir \"$BACKUP_DIR/$BACKUP_DIR_NAME\" Not exist!!! ${NORMAL}"
			log "${GREEN}Success!!! ${NORMAL}"
			fi
			;;
		'n' ) echo "continue without cleaning..." 
		log "continue without cleaning...";;
	esac
			
		
}
removelogs(){
	echo "Are you sure want to remove logs!? y/n"
	read Keypress
	case "$Keypress" in
		'y' ) echo "continue..." ;;
		'n' ) core ;;
	esac
			rm -rf $LOGDIR
			echo "Logs removed. restart script if you need another option." && exit
}
core(){
echo "Which procedure you'll choise?"
echo "(1)-backup .uploads from docker to host"
echo "(2)-restore .uploads from host to docker"
echo "(3)-exit"
echo "(9)-clear temp logs"
echo "(0)-clear temp folder"
			read Keypress
			case "$Keypress" in
			'1' ) backupcorefunc ;;
			'2' ) restorecorefunc ;;	
			'3' ) echo "Bye." && exit ;;
			'9' ) removelogs ;;
			'0' ) removetmp ;;
			esac
}
mailer
checklogdir
core