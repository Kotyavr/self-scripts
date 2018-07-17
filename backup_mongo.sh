#!/bin/sh
#Include folders
APP_NAME="mongodump"
DUMP_NAME="spectre"
DIR=/ADDR_where_local_backup
TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="$APP_NAME-$TIMESTAMP"
LOGDIR=/DIR_ADDR
DUMP_DIR=$DIR/mongo
#mailer


mailer()
{
FROM=mail@mail.com
TO=mail1@mail.com;mail2@mail.com
SUBJECT="Error backup $APP_NAME"
MIME="text/plain"  # Adjust this to the proper mime-type of file
attachment=$LOGDIR/$BACKUP_NAME

ENCODING=base64

boundary="----------------------------"

DATE=`date +"%a, %e %Y %T %z"`

( cat <<EOF
From: $FROM
To: $TO
Subject: $SUBJECT
Date: $DATE
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="$boundary"
Content-Disposition: inline

--$boundary
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Body message: Error backup, details in attached file

--$boundary
Content-Type: $MIME;name="$attachment"
Content-Disposition: attachment;filename="$attachment"
Content-Transfer-Encoding: $ENCODING

EOF

base64 $attachment
echo ""
echo "--$boundary--" ) | sendmail -t
}

checklogdir(){
if [ -d $LOGDIR ];
then
	echo "Log folder exist"
else
	echo "No such log folder was found"
	mkdir $LOGDIR
	echo "Log folder was created"
fi
}
#Log messages to file
log(){
   message="$(date +"%y-%m-%d %T") $@"
   echo $message
   echo $message >>$LOGDIR/$BACKUP_NAME
   }
   #check the dump folder, create if not exist
   checkdir(){
if [ -d $DUMP_DIR ];
	then
	log "\"$DIR\" folder exist"
	else
	log "No such \"dump\" folder was found"
	mkdir $DUMP_DIR
	log "\"$DIR\" folder was created"
	fi
	}
	#do the docker dump and copy it to dump folder
checklogdir
checkdir
log "Prepare mongodump directory"	
	docker exec -it mongodb rm -rf $DIR
log "Temp docker dir \"$DIR\" removed"
	#docker exec -it mongodb mkdir $DIR
log "Temp docker dir \"$DIR\" created"
log "Start mongodump"
docker exec -it mongodb mongodump
log "Mongo dumped"
docker cp mongodb:$DIR/$DUMP_NAME/ $DUMP_DIR/$DUMP_NAME/
if [ -d $DUMP_DIR/$DUMP_NAME ]; then
	log "Mongo dump copyed to temp dir \"$DUMP_DIR/$DUMP_NAME\""
else
	docker exec -it mongodb rm -rf $DIR
	docker exec -it mongodb mongodump
	docker cp mongodb:$DIR/$DUMP_NAME/ $DUMP_DIR/$DUMP_NAME/
	if [ -d $DUMP_DIR/$DUMP_NAME ]; then
		log "Mongo dump copyed to temp dir \"$DUMP_DIR/$DUMP_NAME\""
	else
		log "Error folder not copyed, check original folder for exist"
		log "End with errors!"
		mailer && exit
	fi
fi
#archive mongo dump
tar -zcvf $DUMP_DIR/$DUMP_NAME-$TIMESTAMP.tgz $DUMP_DIR/$DUMP_NAME
if [ -f $DUMP_DIR/$DUMP_NAME-$TIMESTAMP.tgz ]; then
	log "Archive was created"
else
	log "Archivation end with error, no archive was foumd"
	log "End with errors!"
	mailer && exit
fi
rm -rf $DUMP_DIR/$DUMP_NAME
log "Temp dir \"$DUMP_DIR/$DUMP_NAME\" removed"
log "All done! Logs in \"$LOGDIR\"" && exit
