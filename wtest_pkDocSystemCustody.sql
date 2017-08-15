--
-- Unidades de prueba del paquete
--


create or replace Procedure test_pkDocSystemCustody
as
xURL_Nube VARCHAR2(250);
begin

pkDocSystemCustody.AddDocMisDocs(2,	1, 100,	'MI_PDF.PDF', 0, '110',	xURL_Nube);
		
dbms_output.put_line(xURL_Nube);

end;
/



-- ****************************************************************************************
create or replace Procedure test_pkDocSystemCustody
as
xURL_Nube VARCHAR2(250);
begin

pkDocSystemCustody.AddDocImpuestos(2,	1, 1, 100,	'MI_110.PDF', 0, '110',	xURL_Nube);
		
dbms_output.put_line(xURL_Nube);

end;
/


create or replace Procedure test_pkDocSystemCustody
as
xURL_Nube VARCHAR2(250);
begin

pkDocSystemCustody.AddFactGuest('FACTURAS EMITIDAS',
		1,
		1,
		100,
		'fact-LGS 9.pdf', 
		0,
		xURL_Nube);
		
dbms_output.put_line(xURL_Nube);

end;
/



--
--
--
create or replace procedure AddFactGuest(xTipoFact in varchar2,
		xIDInvitado in integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xURL_Nube out varchar2)
as
begin
pkDocSystemCustody.AddFactGuest(xTipoFact,
		xIDInvitado,
		xIDServicio,
		xIDSesion,
		xURL_Local, 
		xNUMERO_Bytes,
		xURL_Nube);
end;
