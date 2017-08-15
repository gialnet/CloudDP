--
--
--
/*

Consulta de los 110 por oden de grabación

select * from doc_custodia where invitado=3 and tipo_documento='110' order by id desc

*/
Create or replace package pkConsultasFiscal AS

Procedure OperacionCredito
	(xInvitado in INTEGER, 
	xTRIM in VARCHAR2, 
	xYEAR in VARCHAR2, 	
	xSESION in INTEGER);
	
Procedure putTempFacturasTrimestre
	(xInvitado in INTEGER, 
	xTRIM in VARCHAR2, 
	xYEAR in VARCHAR2, 
	xSESION in INTEGER);
	
Procedure ResultadosIVATrimestre
	(xInvitado in INTEGER, 
	xTRIM in VARCHAR2, 
	xYEAR in VARCHAR2, 
	xSESION in INTEGER);
	
Procedure listaArchivosPorTipo
	(xInvitado in INTEGER,
	xTipoArchivo in varchar2,
	xPER in VARCHAR2, 
	xYEAR in VARCHAR2, 
	xSESION in INTEGER);
	
Procedure ArchivosDeClientePorTipo
	(xID in INTEGER,
	xTipoArchivo in varchar2,
	xPER in VARCHAR2, 
	xYEAR in VARCHAR2, 
	xSESION in INTEGER);

END pkConsultasFiscal;
/


Create or replace package body pkConsultasFiscal AS

--
--
--
Procedure OperacionCredito(xInvitado in INTEGER, xTRIM in VARCHAR2, xYEAR in VARCHAR2, 	xSESION in INTEGER)
as
CURSOR cCursor IS Select tipo_doc FROM docConsulta 
where id_consulta in 
( Select id from consultas where nombre='operacion credito' and IDGREMIO IN 
	(SELECT IDGREMIO FROM USUARIOS WHERE IDINVITADO=xInvitado)
);

xIDdoc integer;

begin

	DELETE FROM TEMPCONSULTAS WHERE SESION=xSESION;
	
FOR vCURSOR IN cCURSOR LOOP

	-- utilizamos esta técnica desde la optica que los documentos son únicos, es decir no hay dos IVA de un determinado
	-- trimestre.
	begin		
		SELECT ID INTO xIDdoc FROM DOC_CUSTODIA WHERE INVITADO=xInvitado AND TIPO_DOCUMENTO=vCURSOR.TIPO_DOC
		AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='TRIMESTRE' AND VALOR=xTRIM)
		AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='YEAR' AND VALOR=xYEAR);
	exception
   	when no_data_found then
   	    begin
  		continue;
   		end;
   end;
   
	
	INSERT INTO TEMPCONSULTAS (id_doc, sesion) values (xIDdoc,xSESION);
	
	

END LOOP;

end;



--
-- Seleccionar todas las facturas emitidas y recibidas del periodo
-- pasarlas a una tabla temporal para su posteriror tratamiento.
--
Procedure putTempFacturasTrimestre(xInvitado in INTEGER, xTRIM in VARCHAR2, xYEAR in VARCHAR2, xSESION in INTEGER)
as
xIDdoc integer;
CURSOR cCursor IS Select tipo_doc FROM docConsulta 
where id_consulta in 
( Select id from consultas where nombre='libros de iva' and IDGREMIO IN 
	(SELECT IDGREMIO FROM USUARIOS WHERE IDINVITADO=xInvitado)
);
begin

-- limpiar el temporal
DELETE FROM TEMPCONSULTAS WHERE SESION=xSESION;

FOR vCURSOR IN cCURSOR LOOP
	
	INSERT INTO TEMPCONSULTAS (id_doc, sesion, tipo)
	(SELECT ID as id_doc, xSESION as sesion, 
	decode(vCURSOR.TIPO_DOC,'Facturas Emitidas','EM','Facturas Recibidas','RE','IVA Intracomunitario Emitido','IE','IVA Intracomunitario Recibido','IR') as
	tipo
	FROM DOC_CUSTODIA WHERE INVITADO=xInvitado AND TIPO_DOCUMENTO=vCURSOR.TIPO_DOC
    	AND to_char(fecha_doc,'YYYY')=xYEAR and to_char(fecha_doc,'Q')=xTRIM);
	

END LOOP;

end;

--
--
--
Procedure ResultadosIVATrimestre(xInvitado in INTEGER, xTRIM in VARCHAR2, xYEAR in VARCHAR2, xSESION in INTEGER)
as

CURSOR cCursor IS  select id_doc from tempConsultas where sesion=xSESION;

begin 

		-- leer las facturas y ponerlas en un temporal
 		putTempFacturasTrimestre(xInvitado, xTRIM, xYEAR, xSESION);

 		-- limpiamos el temporal de resultados
		DELETE FROM TMPRESULTADOS WHERE SESION=xSESION;
 	
 		
 		-- Facturas emitidas suma total de base, iva, número de documentos y tipo de factura
 		insert into tmpResultados (sesion, iva, base, numfacturas,tipofactura)  		 		
 		(select  xSESION as sesion,valor as iva, sum(base) as base, count(*) as numfacturas ,'EM' as tipofactura
 		from docs_metadatos 
 		where id_doc in 
		(select id_doc from tempConsultas where sesion=xSESION and tipo='EM')
		and atributo='IVA'  group by xSESION,valor,'EM');
		
		-- Facturas recibidas
		insert into tmpResultados (sesion, iva, base, numfacturas,tipofactura)  		 		
 		(select  xSESION as sesion,valor as iva, sum(base) as base, count(*) as numfacturas ,'RE' as tipofactura
 		from docs_metadatos 
 		where id_doc in 
		(select id_doc from tempConsultas where sesion=xSESION and tipo='RE')
		and atributo='IVA'  group by xSESION,valor,'RE');
		
		-- 	IVA intra recibido (nuestra compras a proveedores con domicilio fiscal de la UE)
		insert into tmpResultados (sesion, iva, base, numfacturas,tipofactura)  		 		
 		(select  xSESION as sesion,valor as iva, sum(base) as base, count(*) as numfacturas ,'IR' as tipofactura
 		from docs_metadatos 
 		where id_doc in 
		(select id_doc from tempConsultas where sesion=xSESION and tipo='IR')
		and atributo='IVA'  group by xSESION,valor,'IR');
		
		-- IVA intra emitido (nuestra facturacion a clientes con domicilio fiscal de la UE)
		insert into tmpResultados (sesion, iva, base, numfacturas,tipofactura)  		 		
 		(select  xSESION as sesion,valor as iva, sum(base) as base, count(*) as numfacturas ,'IE' as tipofactura
 		from docs_metadatos 
 		where id_doc in 
		(select id_doc from tempConsultas where sesion=xSESION and tipo='IE')
		and atributo='IVA'  group by xSESION,valor,'IE');
		
 
	
end;

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- Listado de los archivos de un invitado según el tipo de documento seleccionado, el trimestre/mes y año
--------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
Procedure listaArchivosPorTipo(xInvitado in INTEGER,xTipoArchivo in varchar2,
										 xPER in VARCHAR2, xYEAR in VARCHAR2, xSESION in INTEGER)
as
xGremio INTEGER;
xPeriodo CHAR(2);
xTipo VARCHAR2(90);

begin

--SELECCIONAMOS EL GREMIO DEL INVITADO
select idgremio into xGremio from usuarios where idinvitado=xInvitado;

--Buscamos la periodicidad segun el tipo de archivo y el nombre de busqueda
select periodo,tipo_documento into xPeriodo,xTipo from tipos_doc where etiqueta=xTipoArchivo and IDGREMIO=xGremio;

--borramos la tabla temporal de tempconsultas
DELETE FROM TEMPCONSULTAS WHERE SESION=xSESION;



--segun el tipo de archivo tiene una periodicidad hay que hacer un tipo de busqueda
IF (xTipo='Facturas Emitidas' OR xTipo='Facturas Recibidas' 
		OR xTipo='IVA Intracomunitario Emitido' OR xTipo='IVA Intracomunitario Recibido') THEN
		--si el archivo es de tipo factura en doc_metadatos se guarda FECHA
		INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
		(select id as id_doc,xSESION as sesion from doc_custodia 
		where  invitado=xInvitado and tipo_documento=xTipo
		AND to_char(fecha_doc,'YYYY')=xYEAR and to_char(fecha_doc,'MM')=xPER);
END IF;

IF xPeriodo='TR'  THEN 
	
		--busqueda de archivos periodicidad trimestral
		INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
		(select id as id_doc,xSESION as sesion from doc_custodia 
		where  invitado=xInvitado and tipo_documento=xTipo 
		AND ID IN 
		(SELECT  ID_DOC 
		FROM DOCS_METADATOS 
		WHERE ATRIBUTO='TRIMESTRE' AND VALOR=xPER)
		AND ID IN 
		(SELECT  ID_DOC 
		FROM DOCS_METADATOS 
		WHERE ATRIBUTO='YEAR' AND VALOR=xYEAR));
END IF;
		
IF xPeriodo='ME'  THEN 

		--busqueda de archivos periodicidad mensual
		INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
		(select id as id_doc,xSESION as sesion from doc_custodia 
		where  invitado=xInvitado and tipo_documento=xTipo
		AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='MES' AND VALOR=xPER)
		AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='YEAR' AND VALOR=xYEAR));
		
END IF;
		
IF xPeriodo='AN'  THEN 

		--periodicidad anual
		INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
		(select id as id_doc,xSESION as sesion from doc_custodia 
		where  invitado=xInvitado and tipo_documento=xTipo
		AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='YEAR' AND VALOR=xYEAR));


END IF;


end;

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- Buscamos todos los archivos de un cliente por un tipo de archivo
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
Procedure ArchivosDeClientePorTipo
	(xID in INTEGER,
	xTipoArchivo in varchar2,
	xPER in VARCHAR2, 
	xYEAR in VARCHAR2, 
	xSESION in INTEGER)
	
	as
		xGremio INTEGER;
		xPeriodo CHAR(2);
		xTipo VARCHAR2(90);
		
		begin
		
		--SELECCIONAMOS EL GREMIO DEL INVITADO
		select idgremio into xGremio from clientes where id=xID;
		
		--Buscamos la periodicidad segun el tipo de archivo y el nombre de busqueda
		select periodo,tipo_documento into xPeriodo,xTipo from tipos_doc where etiqueta=xTipoArchivo and IDGREMIO=xGremio;
		
		--borramos la tabla temporal de tempconsultas
		DELETE FROM TEMPCONSULTAS WHERE SESION=xSESION;
		
		
		
		--segun el tipo de archivo tiene una periodicidad hay que hacer un tipo de busqueda
		IF xTipo='Facturas Emitidas' OR xTipo='Facturas Recibidas' OR xTipo='IVA Intracomunitario Emitido' OR xTipo='IVA Intracomunitario Recibido' THEN
				--si el archivo es de tipo factura en doc_metadatos se guarda FECHA
				INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
				(select id as id_doc,xSESION as sesion from doc_custodia 
				where  cliente=xID and invitado is NULL and tipo_documento=xTipo
				AND to_char(fecha_doc,'YYYY')=xYEAR and to_char(fecha_doc,'MM')=xPER);
				return;
		END IF;
		
		IF xPeriodo='TR'  THEN 
			
				--busqueda de archivos periodicidad trimestral
				INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
				(select id as id_doc,xSESION as sesion from doc_custodia 
				where  cliente=xID and invitado is NULL  and tipo_documento=xTipo 
				AND ID IN 
				(SELECT  ID_DOC 
				FROM DOCS_METADATOS 
				WHERE ATRIBUTO='TRIMESTRE' AND VALOR=xPER)
				AND ID IN 
				(SELECT  ID_DOC 
				FROM DOCS_METADATOS 
				WHERE ATRIBUTO='YEAR' AND VALOR=xYEAR));
				return;
		END IF;
				
		IF xPeriodo='ME'  THEN 
		
				--busqueda de archivos periodicidad mensual
				INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
				(select id as id_doc,xSESION as sesion from doc_custodia 
				where  cliente=xID and invitado is NULL and tipo_documento=xTipo
				AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='MES' AND VALOR=xPER)
				AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='YEAR' AND VALOR=xYEAR));
				return;
				
		END IF;
				
		IF xPeriodo='AN'  THEN 
		
				--periodicidad anual
				INSERT INTO TEMPCONSULTAS (ID_DOC,SESION)		
				(select id as id_doc,xSESION as sesion from doc_custodia 
				where  cliente=xID and invitado is NULL and tipo_documento=xTipo
				AND ID IN (SELECT  ID_DOC FROM DOCS_METADATOS WHERE ATRIBUTO='YEAR' AND VALOR=xYEAR));
				return;
		
		END IF;

	
	END;

END pkConsultasFiscal;
/