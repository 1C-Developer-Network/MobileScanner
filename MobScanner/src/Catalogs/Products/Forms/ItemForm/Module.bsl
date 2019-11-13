
&AtClient
Procedure OnOpen(Cancel)
	
	If ValueIsFilled(Parameters.parameterSKU) Then 
		
		Object.SKU = Parameters.parameterSKU;
		
	EndIf;
	
	ThisForm.Items.VoiceInput.Enabled = MainModule.UseVoiceInputOfProductDescriptions();
	
EndProcedure

&AtClient
Procedure VoiceInput(Command)
	
	voiceIntent = New MobileDeviceApplicationRun;
	
	voiceIntent.Action = "android.speech.action.RECOGNIZE_SPEECH";
	
	If voiceIntent.Run(True) = 0 Then 
		
	Else 
		
		stringResult = TrimAll(voiceIntent.AdditionalData.Get("query").Value);
		
		stringResult = Upper(Left(stringResult, 1)) + Mid(stringResult, 2);
		
		Object.Description = stringResult;
		
	EndIf;
	
EndProcedure


&AtClient
Procedure SaveAndClose(Command)
	
	ThisObject.Write();
	
	ThisForm.Close(Object.SKU);
	
EndProcedure




