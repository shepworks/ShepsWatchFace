using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.Lang;
using Toybox.Application;



class LayoutsView extends WatchUi.WatchFace {

	// Class properties are loaded first as part of the instance.  
	// These properties are also included in the settings.xml, properties.xml, and strings.xml
	// They are explicitly defined.
	var customFont = null;
	var customFontSmall = null;
	var customIcons = null;
	
	var myBgColor = 0x000000;
	var batteryBorderColor = 0x000000;
	var batteryFillColor = 0x00FF00;
	var topDispColor = 0x000055;
    var midDispColor = 0x000055; 
    var botDispColor = 0x000055;
    
    var hourColor = 0x00FF00;
	var minutesColor = 0x00FF00;
	//var secondsColor = 0x00FF00;
	var dateColor = 0x00FF00; 
	var percentColor = 0x00FF00;

    function initialize() {
        WatchFace.initialize();
       // Application.Storage.setValue("sunrise", "7:19");
    }

    // Load your resources here
    function onLayout(dc) {    
    
	// Downloaded fonts from Google fonts: used Oswald Bold and Roboto Semi-Bold
	// Oswald Bold: Time display. Font size 144 : Roboto Semi-Bold for smaller text
	// Used the BMfont64 app to export installed fonts to bitmap (png) format 
	// Included the space character in the font...otherwise spaces don't render correctly.
	  	customFont = WatchUi.loadResource(Rez.Fonts.customFont);
      	customFontSmall = WatchUi.loadResource(Rez.Fonts.customFontSmall);
      	customIcons = WatchUi.loadResource(Rez.Fonts.customIcons);    
    
        setLayout(Rez.Layouts.WatchFace(dc));
    }   

    // Update the view
    function onUpdate(dc) {
    // Each of these properties is retrieved from the local settings file.
    // The settings file is configured either by the user within Connect IQ Express or while using the Eclipse IDE (connect IQ App Settings Editor)
    // The settings/properties are stored as follows:
    // Eclispse stores them in the users hidden temp directory:  %TEMP%\GARMIN\APPS
    // The watch has the same directory structure under the Apps directory
        myBgColor = Application.getApp().getProperty("BackgroundColor"); 
        batteryBorderColor = Application.getApp().getProperty("BatteryBorderColor");
        batteryFillColor = Application.getApp().getProperty("BatteryFillColor");
        topDispColor = Application.getApp().getProperty("TopDisplayColor");
        midDispColor = Application.getApp().getProperty("MidDisplayColor");
        botDispColor = Application.getApp().getProperty("BottomDisplayColor");
        
        hourColor = Application.getApp().getProperty("HoursColor");
		minutesColor = Application.getApp().getProperty("MinutesColor");
		//secondsColor = Application.getApp().getProperty("SecondsColor");
		dateColor = Application.getApp().getProperty("DateColor");   		
   		 
   		//var theRise = Application.Storage.getValue("sunrise");
		//dc.drawText(x, y, Graphics.FONT_SMALL, "Last location: " + myLastLocation, Graphics.TEXT_JUSTIFY_LEFT);   		 
   		//System.println(theRise);
   		 
   		 
        // redraws the layout every minute        
        dc.clear();
        drawBg(dc);        
        drawTopBox(dc);
        drawMidBox(dc);
        drawBotBox(dc);
        drawTime(dc);
        drawBattery(dc);
        drawDate(dc);
        drawAlarm(dc);
    }
//*********************************************************************************************//
	
	// redraw the background to clear/erase previous views
	private function drawBg(dc){
        dc.setColor(myBgColor, myBgColor);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
    }
	
	private function drawTopBox(dc){
        dc.setColor(topDispColor, topDispColor);
        dc.fillRectangle(0, 0, 240, 77);
    }

	private function drawMidBox(dc){
        dc.setColor(midDispColor, midDispColor);
        dc.fillRectangle(0, 79, 240, 82);
    }

	private function drawBotBox(dc){
        dc.setColor(botDispColor, botDispColor);
        dc.fillRectangle(0, 163, 240, 77);
    }
	// did not include seconds to conserve resources. The seconds only update when the screen is "active."
	private function drawTime(dc) {
        var xBias=0;
        var positionXHours = dc.getWidth()/2-60;
        var positionXSep = dc.getWidth()/2;
        var positionXMinutes = dc.getWidth()/2+60;
        var positionY = 41;         
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var mins = clockTime.min.format("%02d");
        //var secs = clockTime.sec.format("%02d");
        
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }         
        
        if(hours<10){
            xBias= 20;
        }
        // Hour
        dc.setColor(hourColor,Graphics.COLOR_TRANSPARENT);        
        dc.drawText(positionXHours, positionY, customFont, hours, Graphics.TEXT_JUSTIFY_CENTER);
 	     //: Spacer
        dc.setColor(hourColor,Graphics.COLOR_TRANSPARENT);
        dc.drawText(positionXSep-xBias, positionY-8, customFont, ":", Graphics.TEXT_JUSTIFY_CENTER);
 	     //Minutes
        dc.setColor(minutesColor,Graphics.COLOR_TRANSPARENT);
        dc.drawText(positionXMinutes-xBias, positionY, customFont,  mins, Graphics.TEXT_JUSTIFY_CENTER);
        
         //Seconds
        //dc.setColor(secondsColor,Graphics.COLOR_TRANSPARENT);
        //dc.drawText(215, 100, customFontSmall,  secs, Graphics.TEXT_JUSTIFY_CENTER);
    }	

    private function drawBattery(dc){
            
        var positionX = dc.getWidth()/2;  // half of display 240x240 resolution
        var positionY = 164;
   	    var batteryLevel = Math.round(System.getSystemStats().battery);  	    	      
        //System.println(positionX);  // 120 
        // 55% and above = dark green
        // 54 down to 31 = lighter orange
        // 30 or below   = dark orange
        
        if(batteryLevel >= 55){
        	percentColor = 0x00AA00;        
        } else if(batteryLevel < 55 && batteryLevel >= 31) {
        	percentColor = 0xFFAA00;
        } else if(batteryLevel <= 30) {
        	percentColor = 0xFF5500;
        }                      	          
        
       // battery fill color
       // fill rectangle ( x , y , width, height )
        dc.setColor(batteryFillColor,Graphics.COLOR_TRANSPARENT);        
        dc.fillRectangle(positionX-60, 181, 40*(batteryLevel/100), 20);        
        
        // battery outline (font glyph is mapped to the ! character)
        dc.setColor(batteryBorderColor,Graphics.COLOR_TRANSPARENT);
        dc.drawText(positionX-38, positionY+2, customIcons, "!", Graphics.TEXT_JUSTIFY_CENTER); 
        
        // battery percent text
        dc.setColor(percentColor,Graphics.COLOR_TRANSPARENT);
        dc.drawText(positionX+45, positionY+5, customFontSmall, batteryLevel.format("%d")+"%", Graphics.TEXT_JUSTIFY_CENTER); 
        
    }

    private function drawDate(dc){
        var positionY = 35;
        var positionX = dc.getWidth()/2; // center            
		var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		var dateString = Lang.format(
		    "$1$ $2$ $3$",
		    [		        
		        today.day_of_week,
		        today.day,
		        today.month		        
		    ]
		);
		//System.println(dateString); // e.g. "Wed 1 Mar"  		
  		
 		dc.setColor(dateColor,Graphics.COLOR_TRANSPARENT);
        dc.drawText(positionX, positionY, customFontSmall, dateString, Graphics.TEXT_JUSTIFY_CENTER);
    }
    
 	private function drawAlarm(dc){
        var positionY = 2;
        var positionX = dc.getWidth()/2; // center            
		
		if(System.getDeviceSettings().alarmCount>=1)
   	    {
       	    var alarmIcon ='a';
    	    dc.setColor(hourColor,Graphics.COLOR_TRANSPARENT);
            dc.drawText(positionX,positionY, customIcons, "a", Graphics.TEXT_JUSTIFY_CENTER);
   	    } 	
 		
    }    


}
