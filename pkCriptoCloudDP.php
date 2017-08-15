<?php 

	// Tomar un documento y si está encriptado desencriptarlo y mostrarlo en una ventana del navegador

	$DOC=new GetDocCustodia($xIDDoc);
	
	//
	if ($DOC->Encriptado())
	{
		$BF=new BajarFileS3($DOC->xBUCKET,$DOC->xURLNube);
		
		// Descargar archivo cifrado y descifrarlo en tmpBLOB
		$BF->WritetmpBLOB($sesion, $doc, $BF->Download());
		
		// Leer el contenido del archivo desde el campo blob de la tabla tmpBLOB
		
		$original=$BF->ReadtmpBLOB('ORIGINAL');
		
		$DOC->Show($original,$DOC->xURL_LOCAL);
	}
	else
		$DOC->Show();


?>