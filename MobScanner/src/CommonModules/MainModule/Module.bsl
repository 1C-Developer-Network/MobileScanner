Function Sound() Export 
	
	Return Catalogs.Settings.SoundWhenScanningBarcode.Value
	
EndFunction

Function Vibration() Export 
	
	Return Catalogs.Settings.VibrationWhenScanningBarcode.Value;
	
EndFunction

Function UseVoiceInputOfProductDescriptions() Export 
	
	Return Catalogs.Settings.UseVoiceInputOfProductDescriptions.Value;
	
EndFunction

Function PlayTextMessages() Export 
	
	Return Catalogs.Settings.PlayTextMessages.Value;
	
EndFunction

Function TokenDropBox() Export 
	
	Return Constants.TokenDropBox.Get();
	
EndFunction
