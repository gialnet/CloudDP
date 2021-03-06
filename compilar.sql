 --
 -- Archivos de creacion de cloudDP
 -- 22 Dicembre 2010
 -- version 1.5 
 CONNECT SYS AS SYSDBA;
 /
 
CREATE USER "CLOUD_DP_BETA15" PROFILE "DEFAULT" IDENTIFIED BY "a1" DEFAULT TABLESPACE "DATOS" 
TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
/

GRANT "CONNECT" TO "CLOUD_DP_BETA15";
/
-- solo usuario sys

GRANT EXECUTE ON "SYS"."DBMS_CRYPTO" TO "CLOUD_DP_BETA15";
/

-- solo para programación no es posible usarlo en explotación
GRANT "DBA" TO "CLOUD_DP_BETA15" WITH ADMIN OPTION;
/

--creamos los usuarios para cdp
--CL

CREATE USER "CL" PROFILE "DEFAULT" IDENTIFIED BY "a1" DEFAULT TABLESPACE "DATOS" 
TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
/
--IN
--CREATE USER "6fca55ca3c828a46bfe96a10e69f57" PROFILE "DEFAULT" IDENTIFIED BY "bf7ba1ddddb9f133de9cd538c31185" DEFAULT TABLESPACE "DATOS" 
--TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
/

--EM
--CREATE USER "9a6a49a5317fa046854fc275333125" PROFILE "DEFAULT" IDENTIFIED BY "98f26c79ffe5bd1e1b74ed4b431eaa" DEFAULT TABLESPACE "DATOS" 
--TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
/
--WF
--CREATE USER "364b653c82b68bf9eb9396a87de261" PROFILE "DEFAULT" IDENTIFIED BY "665e5f9c1a953761941747aef29271" DEFAULT TABLESPACE "DATOS" 
--TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
/

GRANT "CONNECT" TO "CL";
--cl
--GRANT "CONNECT" TO "466aee172dcb133d1a14592b22c63b";
--in
--GRANT "CONNECT" TO "6fca55ca3c828a46bfe96a10e69f57";
--em
--GRANT "CONNECT" TO "9a6a49a5317fa046854fc275333125";
--wf
--GRANT "CONNECT" TO "364b653c82b68bf9eb9396a87de261";






CONNECT CLOUD_DP_BETA15/a1@clouddp;
/
 

 @MODELO/create_clouddp_beta15.sql;
 @01_VMinimos.sql;
 @02_Funciones.sql;
 @03_pkLogin.sql;
 @04_pkUsuarios_DP.sql;
 @05_pkDocSystemCustody.sql;
 @06_pkCriptoCloudDP.sql;
 @07_pkMensajes.sql;
 @08_pkSesion.sql;
 @09_pkWorkForce.sql;
 @10_pkConsultasFiscal.sql;
 @11_pkEditUsuarios.sql;
 @12_pkTablon.sql;
 @13_pkCarpetas.sql;