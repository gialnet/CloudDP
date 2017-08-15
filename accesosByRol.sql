--crear el ususrio clouddp
CREATE USER "CLOUD_DP_BETA15" PROFILE "DEFAULT" IDENTIFIED BY "a1" DEFAULT TABLESPACE "DATOS" 
TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;

GRANT "CONNECT" TO "CLOUD_DP_BETA15";

-- solo usuario sys

GRANT EXECUTE ON "SYS"."DBMS_CRYPTO" TO "CLOUD_DP_BETA15";


-- solo para programación no es posible usarloen explotación
GRANT "DBA" TO "CLOUD_DP_BETA15" WITH ADMIN OPTION;


--LOGIN
-- Este usuario solo está autorizado a ejecutar el programa pkLogin.
CREATE ROLE "LOGIN_X509" NOT IDENTIFIED;
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKLOGIN" TO "LOGIN_X509";
GRANT "CONNECT" TO "LOGIN_X509";


CREATE USER "LOGIN" PROFILE "DEFAULT" IDENTIFIED BY "A1" DEFAULT TABLESPACE "DATOS" TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "LOGIN";
GRANT "LOGIN_X509" TO "LOGIN";

--CREAR el sinonimo publico para el paquete login.
-- 
CREATE PUBLIC SYNONYM PKLOGIN FOR CLOUD_DP_BETA15.PKLOGIN;

--Tablas
WEB_PERSONAL
INVITADOS
DOC_CUSTODIA
USUARIOS
TIPOS_DOC
TEMPCONSULTAS
vistaSinterfaz
TABLON
FORMASJURIDICAS

GRANT SELECT,INSERT,UPDATE,DELETE ON "CLOUD_DP_BETA15"."WEB_PERSONAL" TO "CLIENTE_CLOUDDP";
GRANT SELECT,INSERT,UPDATE,DELETE ON "CLOUD_DP_BETA15"."TIPOS_DOC" TO "CLIENTE_CLOUDDP";
GRANT SELECT,INSERT,UPDATE,DELETE ON "CLOUD_DP_BETA15"."TEMPCONSULTAS" TO "CLIENTE_CLOUDDP";
GRANT SELECT,INSERT,UPDATE,DELETE ON "CLOUD_DP_BETA15"."VISTASINTERFAZ" TO "CLIENTE_CLOUDDP";
GRANT SELECT,INSERT,UPDATE,DELETE ON "CLOUD_DP_BETA15"."TABLON" TO "CLIENTE_CLOUDDP";
GRANT SELECT,INSERT,UPDATE,DELETE ON "CLOUD_DP_BETA15"."FORMASJURIDICAS" TO "CLIENTE_CLOUDDP";

select idinvitado as id,nif,usuario,movil,email,nombre as razon_social 
from usuarios 
where idcliente=:xIDcliente and tipo='IN'
--
--
--todos los invitados
create or replace view vw_invitados (id,nif,usuario,movil,email,razon_social,idcliente) as
select idinvitado,nif,usuario,movil,email,nombre, idcliente
from usuarios 
where  tipo='IN';
--
--
--invitados activos
create or replace view vw_invitadosActivos (id,nif,usuario,movil,email,razon_social,idcliente) as
select idinvitado,nif,usuario,movil,email,nombre, idcliente
from usuarios 
where  tipo='IN' and idinvitado 
in (select id from invitados where fecha_baja is null);
--
--
--invitados dados de baja
create or replace view vw_invitadosBaja (id,nif,usuario,movil,email,razon_social,idcliente) as
select idinvitado,nif,usuario,movil,email,nombre, idcliente
from usuarios 
where  tipo='IN' and idinvitado 
in (select id from invitados where fecha_baja is not null);

--los documentos de un asesor y que el documento no sea de un invitado ni una nota de voz
select id,to_char(fecha,'DD/MM/YYYY hh:mi:ss') as fecha,url_local,visible,firmado,sellado,cifrado,tipo_documento 
from doc_custodia 
where cliente=:xCliente and invitado is NULL and ubicacion<>'notas_de_voz'

create or replace view vw_docsCliente (id,fecha,url_local,visible,firmado,sellado,cifrado,tipo_documento,cliente) as
select id,to_char(fecha,'DD/MM/YYYY hh:mi:ss'),url_local,visible,firmado,sellado,cifrado,tipo_documento,cliente 
from doc_custodia 
where invitado is NULL and ubicacion<>'notas_de_voz';

select usuario,IDempleado AS ID,NOMBRE,eMAIL,MOVIL,NIF 
from usuarios 
where idcliente=:xIDcliente AND IDEMPLEADO IS NOT NULL

create or replace view vw_empleados (usuario,ID,NOMBRE,eMAIL,MOVIL,NIF,idcliente ) as
select usuario,IDempleado,NOMBRE,eMAIL,MOVIL,NIF,idcliente
from usuarios 
where  IDEMPLEADO IS NOT NULL

select id,to_char(fecha,'DD/MM/YYYY hh:mi:ss') as fecha,url_local,visible,firmado,sellado,cifrado,tipo_documento 
from doc_custodia where invitado=:xGuest

create or replace view vw_docsInvitado (id,fecha,url_local,visible,firmado,sellado,cifrado,tipo_documento,invitado) as
select id,to_char(fecha,'DD/MM/YYYY hh:mi:ss'),url_local,visible,firmado,sellado,cifrado,tipo_documento,invitado
from doc_custodia 

select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS') as fecha,
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=:xSESION)
	
CREATE OR REPLACE VIEW vw_docsByTipo (id,url_local,fecha,sesion) as
select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS'),
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS );
	
create or replace function listDocs(xSESION IN INTEGER) RETURN CURSOR
AS
cCursor(cSesion) Cursor is select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS') as fecha,
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=cSesion);
BEGIN

BEGIN
select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS') as fecha,
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=:xSESION)


END;

-- Buzon de entrada
select p.id,i.razon_social,to_char(p.FECHA,'dd/mm/YYYY hh:mi') as FECHA,p.asunto,p.estado_cliente 
		from peticiones p,invitados i 
		where p.id_cliente=:xCliente and p.id_indirecto=i.id and p.remitente<>:xCliente  order by fecha desc
	
create or replace view vw_buzonEntrada (id,razon_social,fecha,asunto,estado_cliente,id_cliente,remitente) as
select p.id,i.razon_social,to_char(p.FECHA,'dd/mm/YYYY hh:mi'),p.asunto,p.estado_cliente ,p.id_cliente,p.remitente
		from peticiones p,invitados i 
		where p.id_indirecto=i.id order by fecha desc	
		
-- Buzon de salida

select p.id,i.razon_social,to_char(p.FECHA,'dd/mm/YYYY hh:mi') as FECHA,p.asunto,p.estado_cliente 
		from peticiones p,invitados i 
		where p.id_cliente=:xCliente AND p.id_indirecto=i.id and p.remitente=:xCliente  order by fecha desc

create or replace view vw_buzonSalida (id,razon_social,fecha,asunto,estado_cliente,id_cliente,remitente) as
select p.id,i.razon_social,to_char(p.FECHA,'dd/mm/YYYY hh:mi'),p.asunto,p.estado_cliente ,p.id_cliente,p.remitente
		from peticiones p,invitados i 
		where p.id_indirecto=i.id   order by fecha desc	
		
--Asuntos pendientes
select p.id,i.razon_social,to_char(p.FECHA,'dd/mm/YYYY hh:mi') as FECHA,p.asunto,p.estado_cliente 
		from peticiones p,invitados i 
		where p.id_cliente=:xCliente  AND p.id_indirecto=i.id and p.estado_cliente<>'RESUELTA'  order by fecha desc
		
create or replace view vw_asuntosPendientes (id,razon_social,fecha,asunto,estado_cliente,id_cliente) as
		select p.id,i.razon_social,to_char(p.FECHA,'dd/mm/YYYY hh:mi'),p.asunto,p.estado_cliente ,p.id_cliente
		from peticiones p,invitados i 
		where  p.id_indirecto=i.id and p.estado_cliente<>'RESUELTA'  order by fecha desc
		
--Documentos DE LA TABLA TEMP CONSULTAS
select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS') as fecha,
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO,UBICACION
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=:xSESION)
	
create or replace view vw_docConsulta(id,url_local, fecha,VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO,UBICACION) as
select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS'),
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO,UBICACION
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=:xSESION)
		
--hilos de un mensaje
SELECT to_char(FECHA,'dd/mm/YYYY-HH24:MI:SS') as FECHA, MENSAJE,ESTADO_cliente as estado,ID_DOC_ADJUNTO,REMITENTE 
FROM  hilos 
WHERE  id_peticion=:ID_PETI ORDER BY ID DESC

create or replace view vw_hilos ( FECHA, MENSAJE,estado,ID_DOC_ADJUNTO,REMITENTE,id_peticion) as
SELECT to_char(FECHA,'dd/mm/YYYY-HH24:MI:SS'), MENSAJE,ESTADO_cliente,ID_DOC_ADJUNTO,REMITENTE,id_peticion
FROM  hilos 
ORDER BY ID DESC

--INSERT
INSERT INTO TMP_CORPUS

--DELETE
delete from TMP_CORPUS

--PROCEDIMIENTOS
GETALMACENCERT
GETCLIENTDTOANDGROUP
GETCLIENTDTOANDGROUP
GETDEFAULTDTOANDGROUP
GETSESION
PGETMIMETYPEBYIDDOC
PKNOWIFENCRYP



GRANT EXECUTE ON "CLOUD_DP_BETA15"."ACCESSMS" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."E_MAIL_MESSAGE" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."GETALMACENCERT" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."GETCLIENTDTOANDGROUP" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."GETCONNUSER" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."GETDEFAULTDTOANDGROUP" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."GETSESION" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PGETMIMETYPEBYIDDOC" TO "CLIENTE_CLOUDDP"

--PAQUETES
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKCONSULTASFISCAL" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKCRIPTOCLOUDDP" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKDOCSYSTEMCUSTODY" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKEDITUSUARIOS" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKMENSAJES" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKNOWIFENCRYP" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKSESIONES" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKUSERSCDP" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKWORKFORCE" TO "CLIENTE_CLOUDDP"
GRANT EXECUTE ON "CLOUD_DP_BETA15"."PKTABLON" TO "CLIENTE_CLOUDDP"



select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS') as fecha,
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO,UBICACION
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=:xSESION)


CREATE TYPE row_docConsulta AS OBJECT (
  id              	INTEGER,
  URL_LOCAL        	VARCHAR2(250),
  FECHA        		TIMESTAMP(6),
  VISIBLE           CHAR(1),
  CIFRADO			CHAR(1),
  SELLADO			CHAR(1),
  FIRMADO			CHAR(1),
  TIPO_DOCUMENTO	VARCHAR2(90),
  UBICACION			VARCHAR2(250)
);
/

CREATE TYPE table_docConsulta AS TABLE OF row_docConsulta;
/

CREATE OR REPLACE FUNCTION get_docConsulta (
 xSesion in Integer)
  RETURN table_docConsulta AS
  
  v_tab table_docConsulta := table_docConsulta();
BEGIN
  FOR cur IN (select id,url_local,to_char(fecha,'DD/MM/YYYY HH:MM:SS') as fecha,
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO,UBICACION
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=xSesion))
	
	
  LOOP
    v_tab.extend;
    v_tab(v_tab.last) := row_docConsulta(cur.id, cur.url_local, cur.fecha,cur.VISIBLE,
    cur.CIFRADO,cur.SELLADO,cur.FIRMADO,cur.TIPO_DOCUMENTO,cur.UBICACION);
    
  END LOOP;
  RETURN v_tab;
END;
/
