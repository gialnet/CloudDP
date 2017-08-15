/* Setting up a multi-master replication enviroment */

/*Connecting to site win7_10.56.33.21 as user SYSTEM...*/
CONNECT SYSTEM/ ******@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.56.33.21)(PORT=1521)))(CONNECT_DATA=(SID=win7)(server=DEDICATED)));

/* Creating replication administrator at site  win7_10.56.33.21 */
/* Creating user REPADMIN at site  win7_10.56.33.21 */
CREATE USER "REPADMIN" IDENTIFIED BY "******";

/* Granting admin privileges to REPADMIN at site win7_10.56.33.21 */
BEGIN
	DBMS_REPCAT_ADMIN.GRANT_ADMIN_ANY_SCHEMA(
		username => '"REPADMIN"');
END;
/
grant comment any table to "REPADMIN";
grant lock any table to "REPADMIN";
grant select any dictionary to "REPADMIN";

grant analyze any to "REPADMIN";

/* Creating propagator at site  win7_10.56.33.21 */
/* Creating user REPADMIN at site  win7_10.56.33.21 */
/* Registering propagator REPADMIN at site win7_10.56.33.21 */
BEGIN
	DBMS_DEFER_SYS.REGISTER_PROPAGATOR(username => '"REPADMIN"');
END;
/
/* Granting privileges to REPADMIN at site win7_10.56.33.21 */
grant execute any procedure to "REPADMIN";

CONNECT SYSTEM/ ******@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.56.33.21)(PORT=1521)))(CONNECT_DATA=(SID=win7)(server=DEDICATED)));

BEGIN
	 SYSMAN.MGMT_USER.MAKE_EM_USER('REPADMIN');
END;
/
/*Connecting to site win7_10.56.33.21 as user REPADMIN...*/
CONNECT REPADMIN/ ******@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.56.33.21)(PORT=1521)))(CONNECT_DATA=(SID=win7)(server=DEDICATED)))

/* Scheduling purge at site win7_10.56.33.21... */
BEGIN
	DBMS_DEFER_SYS.SCHEDULE_PURGE(
	next_date => to_date('12/10/2010 3.56.0 ','MM/DD/YYYY HH24.MI.SS') ,
	interval => '/*1:Hrs*/ sysdate + 1/24',
	delay_seconds =>0,
	rollback_segment => 'Valor por Defecto');
END;
/


/*Connecting to site win7_10.56.33.21 as user SYSTEM...*/
CONNECT SYSTEM/ ******@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.56.33.21)(PORT=1521)))(CONNECT_DATA=(SID=win7)(server=DEDICATED)));

/* Creating user cloud_dp_beta12 at site  win7_10.56.33.21 */
CREATE USER CLOUD_DP_BETA12 IDENTIFIED BY ******;
grant alter session to CLOUD_DP_BETA12;
grant create cluster to CLOUD_DP_BETA12;
grant create database link to CLOUD_DP_BETA12;
grant create sequence to CLOUD_DP_BETA12;
grant create session to CLOUD_DP_BETA12;
grant create synonym to CLOUD_DP_BETA12;
grant create table to CLOUD_DP_BETA12;
grant create view to CLOUD_DP_BETA12;
grant create procedure to CLOUD_DP_BETA12;
grant create trigger to CLOUD_DP_BETA12;
grant unlimited tablespace to CLOUD_DP_BETA12;
grant create type to CLOUD_DP_BETA12;
grant create any snapshot to CLOUD_DP_BETA12;
grant alter any snapshot to CLOUD_DP_BETA12;


