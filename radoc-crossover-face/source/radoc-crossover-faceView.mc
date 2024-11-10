import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.SensorHistory;


class radoc_crossover_faceView extends WatchUi.WatchFace {

    // Resources
    var fnt_CAL20B = null;


    // Stats
    var showSeconds = false;
    var systemStats = null;
    var deviceSettings = null;    

    var powerBattery = null;
    var solarIntensity = null;
    var dateFormatShort = null;
    var weather = null;
    var notificationCount = -1;
    var bodyBattery = -1;
    var phoneConnected = false;

    private function loadResources() as Void {
        fnt_CAL20B = WatchUi.loadResource(Rez.Fonts.CAL_20B);
    }

    // Internal Functions 1 - Load Stats
    private function loadStats() as Void {
        systemStats = System.getSystemStats(); // System Stats
        solarIntensity = systemStats.solarIntensity; // Solar Intensity
        dateFormatShort = Gregorian.info(Time.now(), Time.FORMAT_SHORT); // Date
        powerBattery = systemStats.battery; // Power Battery
    }

    private function loadStatsLazy() as Void {
        deviceSettings = System.getDeviceSettings(); // Device Settings
        notificationCount = deviceSettings.notificationCount; // Notification Count
        phoneConnected = deviceSettings.phoneConnected; // Phone Connected
        // Body Battery
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            bodyBattery = SensorHistory.getBodyBatteryHistory({:period=>1, :order=> Toybox.SensorHistory.ORDER_NEWEST_FIRST}).next().data;
        }
        weather = Weather.getCurrentConditions(); // Weather
    }

    private function unloadStatsLazy() as Void {
        deviceSettings = null;
        phoneConnected = null;
        weather = null;
        notificationCount = -1;
        bodyBattery = -1;
    }

    // Internal Functions 2 - Mapper 
    private function getWeatherString() as String {
        if(weather == null) { return "???"; }
        switch( weather.condition ){
            case Weather.CONDITION_CLEAR:                       return "Clear";                       
            case Weather.CONDITION_PARTLY_CLOUDY:               return "Partly cloudy";               
            case Weather.CONDITION_MOSTLY_CLOUDY:               return "Mostly cloudy";               
            case Weather.CONDITION_RAIN:                        return "Rain";                        
            case Weather.CONDITION_SNOW:                        return "Snow";                        
            case Weather.CONDITION_WINDY:                       return "Windy";                       
            case Weather.CONDITION_THUNDERSTORMS:               return "Thunderstorms";               
            case Weather.CONDITION_WINTRY_MIX:                  return "Wintery mix";                 
            case Weather.CONDITION_FOG:                         return "Fog";                         
            case Weather.CONDITION_HAZY:                        return "Hazy";                        
            case Weather.CONDITION_HAIL:                        return "Hail";                        
            case Weather.CONDITION_SCATTERED_SHOWERS:           return "Scattered showers";           
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:     return "Scattered thunderstorms";     
            case Weather.CONDITION_UNKNOWN_PRECIPITATION:       return "unknow percipation";          
            case Weather.CONDITION_LIGHT_RAIN:                  return "Light rain";                  
            case Weather.CONDITION_HEAVY_RAIN:                  return "Heavy rain";                  
            case Weather.CONDITION_LIGHT_SNOW:                  return "Light snow";                  
            case Weather.CONDITION_HEAVY_SNOW:                  return "Heavy snow";                  
            case Weather.CONDITION_LIGHT_RAIN_SNOW:             return "Light rain snow";             
            case Weather.CONDITION_HEAVY_RAIN_SNOW:             return "Heavy rain snow";             
            case Weather.CONDITION_CLOUDY:                      return "Heavy cloud";                 
            case Weather.CONDITION_RAIN_SNOW:                   return "Rain Snow";                   
            case Weather.CONDITION_PARTLY_CLEAR:                return "Partly Clear";                
            case Weather.CONDITION_MOSTLY_CLEAR:                return "Mostly Clear";                
            case Weather.CONDITION_LIGHT_SHOWERS:               return "Light Showers";               
            case Weather.CONDITION_SHOWERS:                     return "Showers";                     
            case Weather.CONDITION_HEAVY_SHOWERS:               return "Heavy Showers";               
            case Weather.CONDITION_CHANCE_OF_SHOWERS:           return "Chance of Showers";           
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:     return "Chance of Thunderstorms";     
            case Weather.CONDITION_MIST:                        return "Mist";                        
            case Weather.CONDITION_DUST:                        return "Dust";                        
            case Weather.CONDITION_DRIZZLE:                     return "Drizzle";                     
            case Weather.CONDITION_TORNADO:                     return "Tornado";                     
            case Weather.CONDITION_SMOKE:                       return "Smoke";                       
            case Weather.CONDITION_ICE:                         return "ICE";                         
            case Weather.CONDITION_SAND:                        return "Sand";                        
            case Weather.CONDITION_SQUALL:                      return "Squall";                      
            case Weather.CONDITION_SANDSTORM:                   return "Sand Storm";                  
            case Weather.CONDITION_VOLCANIC_ASH:                return "volcanic ash";                
            case Weather.CONDITION_HAZE:                        return "haze";                        
            case Weather.CONDITION_FAIR:                        return "fair";                        
            case Weather.CONDITION_HURRICANE:                   return "hurricane";                   
            case Weather.CONDITION_TROPICAL_STORM:              return "tropical storm";              
            case Weather.CONDITION_CHANCE_OF_SNOW:              return "chance of snow";              
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:         return "chance of rain snow";         
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:         return "chance of rain snow";         
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:       return "cloudy chance of rain";       
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:       return "cloudy chance of snow";       
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:  return "cloudy chance of rain snow";  
            case Weather.CONDITION_FLURRIES:                    return "flurries";                    
            case Weather.CONDITION_FREEZING_RAIN:               return "Freezing rain";               
            case Weather.CONDITION_SLEET:                       return "Sleet";                       
            case Weather.CONDITION_ICE_SNOW:                    return "Ice Snow";                    
            case Weather.CONDITION_THIN_CLOUDS:                 return "Thin clouds";                 
            case Weather.CONDITION_UNKNOWN:                     return "Weather Unknown";              
        }
        return "New Weather";                    
    }

    private function getWeatherTemperture() as String {
        if(weather == null) { return "???"; }
        return Lang.format("$1$", [weather.temperature.format("%d")]);
    }

    // Internal Functions 3 - Draw Text
    private function drawTopCenter() as Void {
        // Notification Count and Solar Intensity
        if(solarIntensity == null) { solarIntensity = -1;}  
        if(notificationCount == null) { notificationCount = -1;}
        var connectedStr = phoneConnected? "C": "D";
        var text = Lang.format( "$1$ $2$ $3$ ", [ 
            solarIntensity.format("%d"), 
            notificationCount.format("%d") ,
            connectedStr
        ] );
        // Draw Text
        var view = View.findDrawableById("TopCenterLabel") as Text;
        view.setText(text);
        view.setFont(fnt_CAL20B);
    }

    private function drawMiddleRight() as Void {
        var dayOfWeekStr = "";
        switch(dateFormatShort.day_of_week){
            case 1: dayOfWeekStr = "Sun"; break;
            case 2: dayOfWeekStr = "Mon"; break;
            case 3: dayOfWeekStr = "Tue"; break;
            case 4: dayOfWeekStr = "Wed"; break;
            case 5: dayOfWeekStr = "Thu"; break;
            case 6: dayOfWeekStr = "Fri"; break;
            case 7: dayOfWeekStr = "Sat"; break;
            default: dayOfWeekStr = "???"; break;
        }
        var dateString = Lang.format("$2$ $1$  ", [dayOfWeekStr,dateFormatShort.day]);
        // Draw
        var middleRightLabel = View.findDrawableById("MiddleRightLabel") as Text;
        middleRightLabel.setFont(fnt_CAL20B);
        middleRightLabel.setText(dateString);
    } 

    private function drawMiddleLeft() as Void {
        var secondStr = showSeconds ? dateFormatShort.sec.format("%02d"): "-1";
        var middleRightLabel = View.findDrawableById("MiddleLeftLabel") as Text;
        middleRightLabel.setFont(fnt_CAL20B);
        middleRightLabel.setText("       " + secondStr);
    }

    private function drawBottomCenter() as Void {
        var battery = Lang.format("wb $1$% bb $2$% ", [powerBattery.format("%d"), bodyBattery.format("%d")]);
        var text = battery + "\n" +getWeatherString() + " (" + getWeatherTemperture()+")";
        var view = View.findDrawableById("BottomCenterLabel") as Text;
        view.setText(text);
        view.setFont(fnt_CAL20B);
    }


    // Implement Functions
    function initialize() {
        WatchFace.initialize();
        loadResources();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        loadStatsLazy();
        showSeconds = true; 
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        loadStats();
        drawTopCenter();
        drawMiddleLeft();
        drawMiddleRight();
        drawBottomCenter();
        View.onUpdate(dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
       unloadStatsLazy(); 
        showSeconds = false; 
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
