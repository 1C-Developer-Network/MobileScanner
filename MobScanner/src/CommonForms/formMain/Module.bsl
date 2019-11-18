&AtClient
Procedure Scanning(Command)
	
	//GotoURL("e1cib/navigationpoint/desktop/CommonCommand.RunScanning");
	OpenForm("Document.Inventory.ObjectForm");
	
EndProcedure

&AtClient
Procedure InventoryList(Command)
	
	OpenForm("Document.Inventory.ListForm");
	
EndProcedure
