
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	Set = Constants.CreateSet();
	Set.Read();
	
	ValueToFormAttribute(Set, "ConstantsSet");
	
EndProcedure

&AtClient
Procedure OnChangingSettings(Element)

	SaveObject();
		
	RefreshDataRepresentation();
	
EndProcedure

&AtServer
Procedure SaveObject()

	Set = FormAttributeToValue("ConstantsSet");
	Set.Write();

	ValueToFormAttribute(Set, "ConstantsSet");

	Modified = False;

	RefreshReusableValues();

EndProcedure







