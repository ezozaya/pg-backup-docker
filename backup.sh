#!/bin/sh

NOW=$(date +"%Y-%m-%dT%H:%M:%SZ")
FILE="/backups/$NOW.sql.gz"

echo "Creating dump of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."
export PGPASSWORD="$POSTGRES_PASSWORD"
pg_dump -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_DATABASE | gzip > $FILE || exit 3
echo "SQL backup successfull"

if [! -z "$BUCKET"] then
  echo "Uploading dump to $BUCKET"
  # export AWS_ACCESS_KEY_ID
  # export AWS_SECRET_ACCESS_KEY
  # export AWS_DEFAULT_REGION
  cat $FILE | aws $AWS_ARGS s3 cp - s3://$BUCKET/$PREFIX/${POSTGRES_DATABASE}_${NOW}.sql.gz || exit 2
  echo "SQL backup uploaded successfully"
fi

if [! -z "$MAIL_TO"] then
  echo "Sending mail to $MAIL_TO"
  echo "Backup of ${POSTGRES_DATABASE} database successfull at ${NOW}" | mail -v \
    -r $MAIL_FROM \
    -s "[${POSTGRES_DATABASE}] backup ${NOW}" \
    -A $FILE \
    -S smtp="${MAIL_HOST}:${MAIL_PORT}" \
    -S smtp-use-starttls \
    -S smtp-auth=login \
    -S smtp-auth-user=$MAIL_FROM \
    -S smtp-auth-password=$MAIL_PASSWORD \
    -S ssl-verify=ignore \
    $MAIL_TO || exit 5
fi