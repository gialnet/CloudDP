
alter system set LOG_ARCHIVE_START=TRUE SCOPE=spfile;

ALTER SYSTEM SET log_archive_dest = "LOCATION=C:/COPIAS_ORACLE MANDATORY REOPEN = 60" SCOPE=BOTH
ALTER SYSTEM SET log_archive_dest_10 = "LOCATION=USE_DB_RECOBERY_FILE_DEST" SCOPE=BOTH

-- Ver modo de archivado de las instancias
Select NAME, LOG_MODE, CHECKPOINT_CHANGE#,
             ARCHIVE_CHANGE# from V$DATABASE;

ARCHIVE LOG LIST;
             
Al firewall de windows
oracle.exe 
tnslsnr.exe 

El modo archivelog de una base de datos Oracle protege contra la pérdida de datos cuando se produce un fallo en el medio 
físico y es el primer paso para poder hacer copias de seguridad(en caliente!!) con rman. Para poner la base de datos en 
modo archivelog (sin usar la flash recovery area) debemos hacer básicamente dos cosas, añadir dos parámetros nuevos al 
fichero de configuración, reiniciar la base de datos y cambiar el modo trabajo a archivelog.

Como poner la base de datos Oracle 10g en modo archivelog

   1. Editamos el init.ora para añadir los siguientes parámetros
      *.log_archive_dest='/ejemplo/backup/'
      *.log_archive_format='SID_%r_%t_%s'
       
   2. Reiniciamos la base de datos para que coja los cambios y nos aseguramos.
      SQL> shutdown immediate
      Database closed.
      Database dismounted.
      ORACLE instance shut down.
      SQL> startup mount pfile='/ejemplo/pfile/init.ora
      ORACLE instance started.
       
      Total System Global Area  272629760 bytes
      Fixed Size                   788472 bytes
      Variable Size             103806984 bytes
      Database Buffers          167772160 bytes
      Redo Buffers                 262144 bytes
      Database mounted.
      SQL> alter database archivelog;
      Database altered.
      SQL> alter database open;
      Database altered.
      SQL> create spfile;
      SQL> shutdown immediate;
      Database closed.
      Database dismounted.
      ORACLE instance shut down.
      SQL> startup

Backups con RMAN
 
Una vez tenemos la base de datos funcionando en modo archivelog ya podemos plantearnos hacer los backups con rman. Para hacerlos basta con editar un script donde básicamnte hacemos la copia y mantenemos archives en base a cuantos copias queremos mantener y cada cuando ejecutaremos el script. Solo debemos tener cuidado y dimensionar correctamente el número de copias y archivelog que mantemos en base al espacio disponible en el disco. Para saber cuanto espacio necesitaremos podemos aplicar la siguiente formula, suponiendo que la copia sea diaria:

Espacio necesario = (num_backups_rman_mantenidos*tamanyo_backups_rman)+(media_num_redos_al_dia)*(dias_mantenidos).
 

Pasos para empezar a hacer backups:

   1. Editamos el script de sistema para el lanzamiento (/ejemplo/scripts/rman.sh) :
      #!/bin/bash
      export ORACLE_HOME=/opt/oracle/product/10.2/db_1/
      export ORACLE_SID=SID
      /opt/oracle/product/10.2/db_1/bin/rman @/ejemplo/scripts/rman.sql > /backup/scripts/rman.log
       
   2. Script sql que lanzaremos con el sh anterior (/ejemplo/scripts/rman.sql). No hace falta comentarlo porque es muy fácil leer lo que está haciendo en cada paso. Vereis también donde se indica la caducidad de los backups y los archives.

      connect target root/password@SID
      run {
      CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 3 DAYS;

      CONFIGURE CONTROLFILE AUTOBACKUP ON;
      CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/ejemplo/backup/%F';

      CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/ejemplo/backup/%d_%Y%M%D%U';
      CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO COMPRESSED BACKUPSET;
      CONFIGURE MAXSETSIZE TO 8000M;

              backup database
              include current controlfile
              plus archivelog;

      CROSSCHECK BACKUP completed before 'sysdate - 4';       
      DELETE NOPROMPT OBSOLETE;                               
      DELETE NOPROMPT ARCHIVELOG UNTIL TIME "SYSDATE - 4";
      delete noprompt expired backup;
      delete noprompt expired archivelog all;
      report schema;
      }
      exit;
       
   3. Programamos la tarea (crontab?) y listo!! 