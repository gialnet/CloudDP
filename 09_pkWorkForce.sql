--
-- Antonio
-- Octubre 2010
--
-- Trabajos externos, fuerza de trabajo
--
-- En estudio
--
-- Número de documentos pendientes de digitalizar
-- SELECT COUNT(*) FROM DOC_CUSTODIA WHERE WORKFORCE='WA'

Create or replace package pkWorkForce AS

--
-- Solicitar un lote de documentos para trabajar
--
Procedure SolicitarUnLote(xIDServicio IN Integer:=6, xIDWorkForce IN Integer);

--
-- Liberar un lote por parte del usuario
-- 
Procedure LiberarLoteAgent(xLote IN DOC_CUSTODIA.LOTE%Type);

--
-- Trabajo realizado por el agente colaborador
--
Procedure RevisadoDoc(xIDDoc IN Integer);



END pkWorkForce;
/



--
-- Cuerpo del paquete
--
create or replace package body pkWorkForce AS

--
-- Solicitar un lote de documentos para trabajar
--
Procedure SolicitarUnLote(xIDServicio IN Integer:=6, xIDWorkForce IN Integer)
as
	
xINVITADO INTEGER;
xLOTE INTEGER;
begin

-- PETICIONES DE TRABAJO AGRUPADAS POR INVITADO
-- PARA QUE LOS DOCUMENTOS SEAN LO MÁS PARECIDOS
Select INVITADO INTO xINVITADO FROM DOC_CUSTODIA WHERE ROWNUM=1 AND WorkForce='WA';

-- CREAMOS UN NUEVO LOTE
INSERT INTO LOTES_CARGA (DESCRIPCION,WORKFORCE) 
	VALUES ('ASIGNAR LOTE A RECURSO HUMANO',xIDWorkForce) 
	RETURNING ID INTO xLOTE;

-- ASIGNAMOS EL LOTE A LOS DOCUMENTOS
Update Doc_Custodia Set Lote=xLOTE, WorkForce='PR' where WorkForce='WA' AND INVITADO=xINVITADO;

-- ASIGNAMOS LOS CONSUMOS AL RECURSO HUMANO
UPDATE CONSUMOS SET WORKFORCE=xIDWorkForce 
	WHERE ID_SERVICIO=xIDServicio 
		AND WORKFORCE IS NULL 
		AND IDDOC IN (SELECT ID FROM DOC_CUSTODIA WHERE LOTE=xLOTE);



end; -- SolicitarUnLote

--
--
--
Procedure LiberarLoteAgent(xLote IN DOC_CUSTODIA.LOTE%Type)
as
begin

	-- LOTES_CARGA 
	UPDATE LOTES_CARGA SET F_FIN=SYSTIMESTAMP, ESTADO='CC' WHERE ID=xLote;
	
	
	-- QUITAR LOS CONSUMOS AL RECURSO HUMANO
	UPDATE CONSUMOS SET WORKFORCE=NULL 
	WHERE IDDOC IN (SELECT ID FROM DOC_CUSTODIA WHERE LOTE=xLOTE AND WorkForce='PR');

	-- QUITAR EL LOTE A LOS DOCUMENTOS
	UPDATE Doc_Custodia SET Lote=NULL, WorkForce='WA' WHERE LOTE=xLote AND WorkForce='PR';

end; -- LiberarLote()


--
-- Revisar un documento
--
Procedure RevisadoDoc(xIDDoc IN Integer)
as
begin


	UPDATE DOC_CUSTODIA SET WorkForce='OK' WHERE ID=xIDDoc;
	

end; -- RevisadoDoc()

END pkWorkForce;
/