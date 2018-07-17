#!/bin/bash
APP_NAME="spectre-images"
APP_FOLD=".uploads"
TIMESTAMP=`date +%F-%H%M`
DUMP_DIR=/DUMP_DIR_ADDR
LOGDIR=/DIR_ADDR
BACKUPS_DIR=/ADDR_where_local_backup
BACKUP_NAME="$APP_NAME-$TIMESTAMP"
#mailer


mailer()
{
FROM=mail@mail.com
TO=mail@mail.com;mail2@mail.com
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
Body message: Error backup uploads, details in attached file.

--$boundary
Content-Type: $MIME;name="$attachment"
Content-Disposition: attachment;filename="$attachment"
Content-Transfer-Encoding: $ENCODING

EOF

base64 $attachment
echo ""
echo "--$boundary--" ) | sendmail -t
}

 checklogdir(){ if [ -d $LOGDIR ]; then
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
 checkdir(){ if [ -d $DUMP_DIR ]; then
	log "Images dump folder exist"
	else
	log "No such \"images\" dump folder was found"
	mkdir $DUMP_DIR
	log "Folder \"$DUMP_DIR\" was created"
	fi
}
checklogdir
checkdir
cp -r $BACKUPS_DIR/$APP_FOLD/ $DUMP_DIR/$APP_FOLD/
if [ -d $DUMP_DIR/$APP_FOLD/ ]; then
	log "Origilan img folder copyed to temp dir \"$DUMP_DIR/$BACKUP_NAME\""
	else
	log "Error folder not copyed, check original folder for exist or privileges" 
	log "End with errors!"
	mailer && exit
	fi
	tar -zcvf $DUMP_DIR/uploads-$TIMESTAMP.tgz $DUMP_DIR/$APP_FOLD
	if [ -f $DUMP_DIR/uploads-$TIMESTAMP.tgz ]; then
	log "Archive was created"
	else
	log "Archivation end with error, no archive was found"
	log "End with errors!"
	mailer && exit
	fi
rm -rf $DUMP_DIR/$APP_FOLD log "Folder \"$DUMP_DIR/$BACKUP_NAME\" removed"
log "All done! Logs in $LOGDIR" && exit
