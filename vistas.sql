
-- CLIENTES

-- TODOS LOS DOCUMENTOS DE UN CLIENTE
select ID,FECHA,URL_LOCAL from doc_custodia where cliente= ORDER BY ID DESC

-- TODOS LOS DOCUMENTOS DE UN CLIENTE DEL TIPO DE DOCUMENTO
select ID,FECHA,URL_LOCAL from doc_custodia where cliente= AND tipo_documento= ORDER BY ID DESC

-- TODOS LOS DOCUMENTOS DE UN CLIENTE EN UNA CARPETA
select ID,FECHA,URL_LOCAL from doc_custodia where cliente= AND ubicacion= ORDER BY ID DESC

-- TODOS LOS DOCUMENTOS DE UN CLIENTE QUE PERTENECEN A UN GRUPO
select ID,FECHA,URL_LOCAL from doc_custodia where cliente= AND grupo= ORDER BY ID DESC


-- NOTAS DE VOZ notas_de_voz
select ID,FECHA,URL_LOCAL from doc_custodia where cliente= AND ubicacion='notas_de_voz' ORDER BY ID DESC

-- Todos los EMPLEADOS de un CLIENTE
select ID,NOMBRE,MAIL,MVL from clientes where pertenece_a=xIDcliente






-- USUARIOS

-- ID DE CLIENTE POR NIF
select TIPO,USUARIO,NOMBRE,IDCLIENTE FROM USUARIOS WHERE USUARIO='B18874941'

-- TODOS LOS USUARIOS DE UN CLIENTE
select TIPO,USUARIO,NOMBRE,IDCLIENTE,IDINVITADO FROM USUARIOS WHERE IDCLIENTE=1

-- TODOS LOS EMPLEADOS DE UN CLIENTE
select TIPO,USUARIO,NOMBRE,IDCLIENTE,IDINVITADO FROM USUARIOS WHERE IDCLIENTE=1 AND TIPO='EM'

-- TODOS LOS INVITADOS DE UN CLIENTE
select TIPO,USUARIO,NOMBRE,IDCLIENTE,IDINVITADO FROM USUARIOS WHERE IDCLIENTE=1 AND TIPO='EM'



-- EMPLEADOS


-- TODOS LOS DOCUMENTOS DE UN EMPLEADO
select ID,FECHA,URL_LOCAL from doc_custodia where empleado= ORDER BY ID DESC

-- TODOS LOS DOCUMENTOS DE UN EMPLEADO EN UNA CARPETA
select ID,FECHA,URL_LOCAL from doc_custodia where empleado= AND ubicacion= ORDER BY ID DESC

-- TODOS LOS DOCUMENTOS DE UN EMPLEADO QUE PERTENECEN A UN GRUPO
select ID,FECHA,URL_LOCAL from doc_custodia where empleado= AND grupo= ORDER BY ID DESC




-- INVITADOS

-- TODOS LOS DOCUMENTOS DE UN INVITADO
select ID,FECHA,URL_LOCAL from doc_custodia where invitado= ORDER BY ID DESC


-- DOCUMENTOS EN FUNCION DE SUS METADATOS
select c.ID,c.FECHA,c.URL_LOCAL,m.ATRIBUTO,m.VALOR from doc_custodia c, docs_metadatos m 
		where c.cliente=m.id_doc
		and c.invitado=
		and m.atributo=
		and m.valor=
		
		ORDER BY c.ID DESC

		

--Vista de todos los clientes que estan activos
select u.usuario,u.nombre,u.idcliente,u.idinvitado,u.tipo from usuarios u, clientes c 
where u.usuario=c.nif and u.tipo='CL' and c.fecha_baja is null;

--Vista de todos los clientes que estan de baja
select u.usuario,u.nombre,u.idcliente,u.idinvitado,u.tipo from usuarios u, clientes c 
where u.usuario=c.nif and u.tipo='CL' and c.fecha_baja is not null;

-- Lista de empleados de clientes activos
select u.usuario,u.nombre,u.idcliente,u.idinvitado,u.tipo from usuarios u, clientes c 
where u.usuario=c.nif and u.tipo='EM' and c.fecha_baja is null;


-- Lista de Invitados de clientes activos
select u.usuario,u.nombre,u.idcliente,u.idinvitado,u.tipo from usuarios u, invitados I 
where u.IDCliente=I.IDCliente and u.tipo='IN' and I.fecha_baja is null AND I.estado='OPEN';





-- LAS CONDICIONES SON: coincidir el número de movil, la contraseña aleatoria 
-- y el tiempo de caducidad de la contraseña no se ha alcanzado.
	
SELECT G.ID, U.IDCliente, U.IDInvitado, U.TIPO, U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE,U.USUARIO
			INTO  xIDGremio, xIDCliente, xIDInvitado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE,xNIF
			FROM USUARIOS U, GREMIOS G
      			WHERE U.USUARIO=xUsuario
      			AND	U.SMS_PASS=xSMS_PASS 
      			AND U.IDGREMIO=G.ID
      			AND U.SMS_UNTIL >= SYSTIMESTAMP;
      			
-- Via DNIe o Certificado
CREATE OR REPLACE FORCE VIEW VW_LOGIN_X509 ("IDGREMIO","IDCLIENTE","IDINVITADO","IDEMPLEADO","ROLE",
							"IDDATOSPER","DIGITOS","PERFIL","EMAIL","NOMBRE")
				AS SELECT G.ID, U.IDCliente, U.IDInvitado,U.IDEmpleado, U.TIPO, 
					U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE
				INTO  xIDGremio, xIDCliente, xIDInvitado,xIDEmpleado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE
				FROM USUARIOS U, GREMIOS G
      			WHERE USUARIO=xUsuario AND U.NIF=trim(xNIF) AND U.IDGREMIO=G.ID;
      			
-- Coordenadas
SELECT G.ID, U.IDCliente, U.IDInvitado,U.IDEMPLEADO, U.TIPO, U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE
			INTO  xIDGremio, xIDCliente, xIDInvitado,xIDEmpleado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE
			FROM USUARIOS U, GREMIOS G
      			WHERE U.USUARIO=xUSUARIO AND U.IDGREMIO=G.ID;      			