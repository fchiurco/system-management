#Script di backup e rotation per Pgsql o mysql
#Postgres MySQL
#non è una rotation vera e propria, cancella i file più vecchi di 30 gg
# cd /etc/cron.daily/
# touch /etc/cron.daily/dbbackup-daily.sh
# chmod 755 /etc/cron.daily/dbbackup-daily.sh
# vi /etc/cron.daily/dbbackup-daily.sh
# f.chiurco@inapp.org


#!/bin/sh
adesso="$(date +'%d_%m_%Y_%H_%M_%S')" #Data ora minuti e secondi dell'esecizione dello script
nome_db=pg_isfol_db
utente_db=postgres
nome_utente=postgres #utente sistema (per dare i permessi corretti)

nomefile="$nome_db"_"$adesso".sql.gz
echo "nome backup = $nomefile"
dirbackup="/data/backup/rotation_test"

percorso_backup="$dirbackup/$nomefile"
file_log="$dirbackup/"backup_log_"$(date +'%Y_%m')".log
echo "file_log="$file_log
echo "dump iniziato $(date +'%d-%m-%Y %H:%M:%S')" >> "$file_log"
#mysqldump --user=mydbuser --password=mypass --default-character-set=utf8 mydatabase | gzip > "$percorso_backup"
su - postgres -c "pg_dump -U $utente_db $nome_db  | gzip > "$percorso_backup""

##if [ "$?"-ne 0]; then echo "Help" | mail -s "Backup failed" you@example.com; exit 1; fi

echo "dump terminato  $(date +'%d-%m-%Y %H:%M:%S')" >> "$file_log"
chown $nome_utente "$percorso_backup"
chown $nome_utente "$file_log"
echo "Permessi file cambiati" >> "$file_log"


#Cancellare vecchi dump:
echo "File da cancellare  $(date +'%d-%m-%Y %H:%M:%S')" >> "$file_log"
find "$dirbackup" -name $nome_db\* -mtime +31 -exec ls -l {} \; >> $file_log  #trova i file più vecchi di 31 giorni (verifica funzion).
find "$dirbackup" -name $nome_db\* -mtime +31 -exec rm {} \; #cancella i file più vecchi di 31 giorni.
echo "vecchi file cancellati" >> "$file_log"
echo "operazione terminata  $(date +'%d-%m-%Y %H:%M:%S')" >> "$file_log"
echo "*************************+++++++++++++++++***********************" >> "$file_log"
exit 0
