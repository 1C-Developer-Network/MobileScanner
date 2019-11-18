
&AtClient
Procedure OnOpen(Cancel)
	
	If Not MultimediaTools.BarcodeScanningSupported() Then 
		Message("Barcode scanning not supported");
		Items.buttonReadBarcode.Enabled = False;
	EndIf;
	
EndProcedure

&AtClient
Procedure ReadBarcode(Command)
	
	ScanningHandler = New NotifyDescription("ScanResult", 			ThisObject);
	CloseHandler	= New NotifyDescription("ClosingScanWindow", 	ThisObject);
	
	MultimediaTools.ShowBarcodeScanning(
											"Point the camera to the barcode",
											ScanningHandler,
											CloseHandler
	);
	
	
EndProcedure

&AtClient
Procedure ScanResult(BarCode, Result, Message, ExtraOptions) Export 
	
	If Result Then 
		
		MultimediaTools.PlaySoundAlert(PlaySoundWhenScanning(), MainModule.Vibration());
		
		resultFinding = FindOnServer(BarCode);
		
		If Not resultFinding = False Then 
			
			AddProduct(resultFinding, BarCode);
			
		Else 
			
			MultimediaTools.CloseBarcodeScanning();
			
			structureParameters = New Structure;
			
			structureParameters.Insert("parameterSKU", BarCode);
			
			formNewProduct = GetForm("Catalog.Products.ObjectForm", structureParameters);
			newSKU = formNewProduct.DoModal();
			
			If ValueIsFilled(newSKU) Then 
				
				resultFinding = FindOnServer(newSKU);
				
				AddProduct(resultFinding, newSKU);
				
			EndIf;
			
		EndIf;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure ClosingScanWindow(ExtraOptions) Export
	
	//
	
EndProcedure

&AtClient
Procedure AddProduct(Product, SKU)
	
	SearchOptions = New Structure;
	SearchOptions.Insert("SKU", SKU);
	
	FoundLines = Object.Products.FindRows(SearchOptions);
	
	If FoundLines.Count() = 0 Then 
		
		NewLine = Object.Products.Add();
		
		NewLine.Product		= Product;
		NewLine.SKU 		= SKU;
		NewLine.Quantity 	= 1;
		
	Else 
		
		FoundLine = FoundLines[0];
		FoundLine.Quantity = FoundLine.Quantity + 1;
		
	EndIf;
	
	ThisObject.Write();
	
EndProcedure

&AtClient
Function PlaySoundWhenScanning()
	
	If MainModule.Sound() Then 
		Return SoundAlert.Default;
	Else 
		Return SoundAlert.None;
	EndIf;
	
EndFunction

&AtServer
Function FindOnServer(BarCode)
	
	Query = New Query;
	
	Query.Text = "SELECT
	             |	Products.Ref AS Ref
	             |FROM
	             |	Catalog.Products AS Products
	             |WHERE
	             |	Products.SKU = &SKU";
	
	Query.SetParameter("SKU", TrimAll(BarCode));
		
	resultQuery = Query.Execute().Select();
	
	If resultQuery.Next() Then 
		Return resultQuery.Ref;
	Else 
		Return False;
	EndIf;
	
EndFunction

&AtClient
Procedure PostToDropBox(Command)
	
	If Object.Products.Count() = 0 Then 
		
		ReportStatus("No data for send");
		
		Return;
	EndIf;
	
	structureResult = PostToDropBoxAtServer();
	
	If structureResult.Status Then 
		ReportStatus("File uploaded successfully");
	Else 
		ReportStatus(structureResult.Description);
	EndIf;

EndProcedure

&AtServer
Function PostToDropBoxAtServer()
	
	newSpreadsheetDocument = New SpreadsheetDocument;
	
	Section = newSpreadsheetDocument.GetArea("R1");
	
	Section.Area("R1"+"C1").Text = "Number";
	Section.Area("R1"+"C2").Text = "Product";
	Section.Area("R1"+"C3").Text = "SKU";
	Section.Area("R1"+"C4").Text = "Quantity";
	
	counter = 1;
	
	For Each curProduct In Object.Products Do 
		
		counter = counter + 1;

		Section.Area("R" + String(counter) + "C1").Text = counter - 1;
		Section.Area("R" + String(counter) + "C2").Text = curProduct.Product;
		Section.Area("R" + String(counter) + "C3").Text = curProduct.SKU;
		Section.Area("R" + String(counter) + "C4").Text = curProduct.Quantity;
		
	EndDo;
	
	ShortTempFileName 	= String(Object.Number) + ".pdf";
	FullTempFileName 	= TempFilesDir() + String(Object.Number) + ".pdf";
	
	newSpreadsheetDocument.Put(Section);
	
	newSpreadsheetDocument.Write(FullTempFileName, SpreadsheetDocumentFileType.PDF);
	
	
	
	tokenDropBox = MainModule.TokenDropBox();

	ServerName = "content.dropboxapi.com";
	URL = "/2/files/upload";
	
	ShortTempFileName = "/" + ShortTempFileName;
	
	Headers = New Map;
	
	DropBoxAPIArg = "{""path"": " + """" + ShortTempFileName + """" + ",""mode"": ""overwrite""}";

	Headers.Insert("Dropbox-API-Arg", DropBoxAPIArg);
	Headers.Insert("Authorization", "Bearer " + tokenDropBox);
	Headers.Insert("Content-Type", "application/octet-stream");
	Headers.Insert("Accept", "application/octet-stream");
		
	HttpQuery = New HTTPRequest(URL, Headers);
	
	HttpQuery.SetBodyFileName(FullTempFileName);
		
	HttpConnection = New HTTPConnection(ServerName, 443,,,,, New OpenSSLSecureConnection);
	
	HttpAnswer = HttpConnection.Post(HttpQuery, "");
	
	BodyAnswer = HttpAnswer.GetBodyAsString(TextEncoding.UTF8);
	
	structureResult = New Structure;
	structureResult.Insert("Status");
	structureResult.Insert("Description");
	
	If (HttpAnswer.StatusCode < 200) Or (HttpAnswer.StatusCode >= 300) Then 
		
		ErrorDescription = "An error occurred while uploading!" + Chars.LF;
		ErrorDescription = ErrorDescription + "Status code: " + HttpAnswer.StatusCode + Chars.LF;
		ErrorDescription = ErrorDescription + "Body answer: " + BodyAnswer;
		
		structureResult.Status = False;
		structureResult.Description = ErrorDescription;
		
	Else 
		
		structureResult.Status = True;
		
	EndIf;
	
	Return structureResult;
	
EndFunction

&AtClient
Procedure  ReportStatus(TextMessage)
	
	If MultimediaTools.TextPlaybackSupported() And MainModule.PlayTextMessages() Then 
		MultimediaTools.PlayText(TextMessage);
	Else 
		Message(TextMessage);
	EndIf;
	
EndProcedure




