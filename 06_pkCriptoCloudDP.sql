--
-- Antonio
-- Septiembre 2010
--
-- Gestión criptográfica de Cloud DP
--
--


Create or replace package pkCriptoCloudDP AS

--
-- Cifrar un documento
--
-- xIDAlmacenCert nos da el valor del ID de la tabla de almacen de certificados
--
PROCEDURE CifrarAES256(xIDAlmacenCert in Integer, xIDSesion in Integer, xORIGINAL in BLOB);

-- Descifrar un documento por ID
Procedure DesCifrarAES256ByIDDoc(xIDDoc in Integer, xIDSesion in INTEGER, xBFileCifrado in BLOB);

-- Guardar clave publica de un certificado de cliente
Procedure SaveClientPKCS7(xIDCliente in Integer, xPKCS7 in BLOB);


--
-- Descifrar el contenido de un archivo con su clave de cifrado y guardar el resultado en la tabla temporal tmpBLOB
-- en el campo ORIGINAL y CIFRADO
--
Procedure DecryptWrite_tmpBLOB(xIDSesion IN Integer,xIDDoc in INTEGER, xContenFileCifrado IN BLOB);

--
-- Firma de Servidor de un documento, firmar con el certificado del servidor HTTP
--
-- Grabar el contenido de una firma mediante OpenSSL
--
Procedure OpenSSLFirmar(xFirmaRAW in BLOB, xIDDoc in integer);

--
-- Funcion hash
--
Function HashFileSH1(xBLOB IN BLOB) return varchar2;

-- el hash del campo cifrado
PROCEDURE SetCifradoHASH_SH1(xIDDoc In Integer, xIDSesion In Integer);

-- el hash del campo original
PROCEDURE SetOriginalHASH_SH1(xIDDoc In Integer, xIDSesion In Integer);

		
END pkCriptoCloudDP;
/






--
-- Cuerpo del paquete
--
create or replace package body pkCriptoCloudDP AS


--
-- hash del Original
--
PROCEDURE SetOriginalHASH_SH1(xIDDoc In Integer, xIDSesion In Integer)
AS
xBFile BLOB;
BEGIN

begin
Select original into xBFile from tmpBLOB where IDSESION=xIDSesion;
Exception
   	When no_data_found then
 		begin  	
  		  	RETURN;
   		end;
	END;

UPDATE DOC_CUSTODIA SET HASH_SH1=HashFileSH1(xBFile) WHERE ID=xIDDoc;

END;
--
-- hash del cifrado
--
PROCEDURE SetCifradoHASH_SH1(xIDDoc In Integer, xIDSesion In Integer)
AS
xBFile BLOB;
BEGIN

begin
Select Cifrado into xBFile from tmpBLOB where IDSESION=xIDSesion;
Exception
   	When no_data_found then
 		begin  	
  		  	RETURN;
   		end;
	END;
	
UPDATE DOC_CUSTODIA SET HASH_SH1=HashFileSH1(xBFile) WHERE ID=xIDDoc;

END;
--
--
--
Function HashFileSH1(xBLOB IN BLOB) return varchar2
as
xTipo PLS_INTEGER := dbms_crypto.HASH_SH1;
xHASH_SH1 Raw(2000);
var_hash_sh1 varchar2(200);
begin


xHASH_SH1:=DBMS_CRYPTO.Hash (src => xBLOB, typ => xTipo);
var_hash_sh1:=lower(rawtohex(xHASH_SH1));

return var_hash_sh1;

end;
--
-- Grabar la firma de un docuemnto mediante OpenSSL
-- Abril 2010
--

Procedure OpenSSLFirmar(xFirmaRAW in BLOB, xIDDoc IN integer)
as
xFB64 blob;
BEGIN

	-- Leer el descriptor de blob para actualización
	SELECT CIFRADO INTO xFB64 FROM tmpBLOB WHERE IDSesion=xIDDoc FOR UPDATE;

	-- UTL_ENCODE.BASE64_ENCODE esta función pasa de binario a base 64
	DBMS_LOB.APPEND(xFB64, UTL_ENCODE.BASE64_ENCODE(xFirmaRAW));
	
	
	UPDATE DOC_CUSTODIA SET FIRMADO='S' WHERE ID=xIDDoc;

END;


--
-- Descifrar el contenido de un archivo con su clave de cifrado y guardar el resultado en la tabla temporal tmpBLOB
-- en el campo ORIGINAL y CIFRADO
--
Procedure DecryptWrite_tmpBLOB(xIDSesion IN Integer,xIDDoc in INTEGER, xContenFileCifrado IN BLOB)
as
xCIFRADO BLOB;
xORIGINAL BLOB;
-- total encryption type
encryption_type PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;

key_bytes_raw RAW (32); -- stores 256-bit encryption key

begin

	BEGIN
		
		SELECT AES INTO key_bytes_raw FROM ALMACENCERT 
			WHERE ID = (SELECT ALMACENCERT FROM DOC_CUSTODIA WHERE ID=xIDDoc);
			
	Exception
   	When no_data_found then
 		begin  	
  		  	RETURN;
   		end;
	END;
	
	DELETE FROM  tmpBLOB WHERE IDSESION=xIDSesion;
	
	INSERT INTO tmpBLOB (IDSESION, ORIGINAL, CIFRADO) values (xIDSesion, Empty_Blob(), Empty_Blob());
	
	SELECT ORIGINAL, CIFRADO INTO xORIGINAL,xCIFRADO FROM tmpBLOB WHERE IDSESION=xIDSesion FOR UPDATE;
	
	DBMS_LOB.APPEND(xCIFRADO, xContenFileCifrado);
	
	DBMS_CRYPTO.DECRYPT(dst => xORIGINAL, src =>xCIFRADO, typ => encryption_type, key => key_bytes_raw);
	
end;


--
-- Cifrar un documento via AES 256
--
PROCEDURE CifrarAES256(xIDAlmacenCert in Integer, xIDSesion in Integer, xORIGINAL in BLOB)
AS

xBFileCifrado BLOB;

key_bytes_raw RAW (32); -- stores 256-bit encryption key

-- total encryption type
encryption_type PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;

BEGIN

	--
	-- Leer la clave de encriptación
	--
	BEGIN
		SELECT AES INTO key_bytes_raw FROM ALMACENCERT WHERE ID=xIDAlmacenCert;
	Exception
   	When no_data_found then
 		begin  		
  		  	RETURN;
   		end;
	END;
	
	BEGIN
		SELECT CIFRADO INTO xBFileCifrado FROM tmpBLOB WHERE IDSESION=xIDSesion FOR UPDATE;
	Exception
   	When no_data_found then
 		begin  		
  		  	RETURN;
   		end;
	END;
	
	
	DBMS_CRYPTO.ENCRYPT(dst => xBFileCifrado, src => xORIGINAL, typ => encryption_type, key => key_bytes_raw);
	

END;

--
-- Descifrar un archivo sabiendo el ID de la tabla DOC_CUSTODIA
--
Procedure DesCifrarAES256ByIDDoc(xIDDoc in Integer, xIDSesion in INTEGER, xBFileCifrado in BLOB)
as

xORIGINAL BLOB;
-- total encryption type
encryption_type PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;

key_bytes_raw RAW (32); -- stores 256-bit encryption key


begin

	-- Leer la clave de encriptación
	--
	BEGIN
		
		SELECT AES INTO key_bytes_raw FROM ALMACENCERT 
			WHERE ID = (SELECT ALMACENCERT FROM DOC_CUSTODIA WHERE ID=xIDDoc);
			
	Exception
   	When no_data_found then
 		begin  	
  		  	RETURN;
   		end;
	END;
	
	BEGIN
		SELECT ORIGINAL INTO xORIGINAL FROM tmpBLOB WHERE IDSESION=xIDSesion FOR UPDATE;
	Exception
   	When no_data_found then
 		begin  		
  		  	RETURN;
   		end;
	END;
	
	DBMS_CRYPTO.DECRYPT(dst => xORIGINAL, src =>xBFileCifrado, typ => encryption_type, key => key_bytes_raw);

end;

--
-- Guardar clave publica de un certificado de cliente
--
Procedure SaveClientPKCS7(xIDCliente in Integer, xPKCS7 in BLOB)
as
xPUBLICA BLOB;
begin

	BEGIN
		-- Guardar la clave publica de un certificado	
		SELECT PUBLICA INTO xPUBLICA FROM ALMACENCERT 
			WHERE ID = (SELECT ALMACENCERT FROM CLIENTES WHERE ID=xIDCliente) FOR UPDATE;
	Exception
   	When no_data_found then
 		begin  	
  		  	RETURN;
   		end;
	END;
	
	DBMS_LOB.APPEND(xPUBLICA, xPKCS7);
	
	COMMIT;
	
end;



END pkCriptoCloudDP;
/