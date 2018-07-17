#!/bin/sh
#Include folders
APP_NAME="backup-to-S3"
DIR=/ADDR_where_local_backup
TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="$APP_NAME-$TIMESTAMP"
LOGDIR=/DIR_ADDR
#mailer


mailer()
{
FROM=mail@mail.com
TO=mail1@mail.com;mail2@mail.com
SUBJECT="Attention $APP_NAME"
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
Body message: $TGR

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
#Check folder mongo and sync with Amazon S3 it exist
checkmongo(){
if [ -d $DIR/mongo ];
	then
	log "Check mongo dump dir pass!"
	log "Synchronize mongo_dump"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $DIR/mongo/ s3://ADDR/
	log "mongo_dump copyed"
else
	log "No mongo backup!"
	TGR="No mongo backup!"
	mailer 
fi
}
#Check folder images and sync with Amazon S3 it exist
checkimages(){
if 	[ -d $DIR/images ];
	then
	log "Check images dump dir pass!"
	log "Synchronize images_dump"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $DIR/images/ s3://ADDR/
	log "images_dump copyed"
else
	log "No images backup!"
	TGR="No mongo backup!"
	mailer 
fi
}
#Check folder for exiist and call functions upper this conf
checklogdir
if [ -d $DIR ];
then
	log "Check \"$DIR\" folder pass!"
	checkmongo
	checkimages
	log "All data copyed"
	log "Removing temporary dump directories"
	rm -rf $DIR/mongo
	rm -rf $DIR/images
	log "Temporary \"dump\" directories removed"
else
	log "Nothing to backup"
	log "No files or directory"
	TGR="Nothing to backup"
	#rm -rf $DIR/mongo
	#rm -rf $DIR/images
	log "Temporary \"dump\" directories removed"
	mailer
fi
log "All done! Logs in $LOGDIR" && exit

