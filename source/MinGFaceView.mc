import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
using Toybox.UserProfile;

class MinGFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        //setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        // Load colors from properties
        var timeColor = Properties.getValue("TimeColor");
        var batteryColor = Properties.getValue("BatteryColor");
        var distanceColor = Properties.getValue("DistanceColor");
        var tempColor = Properties.getValue("TempColor");
        var heartColor = Properties.getValue("HeartColor");
        var lines = Properties.getValue("Lines");
        var transparent = Graphics.COLOR_TRANSPARENT;

        // Load fonts
        var futura2XL = loadResource(Rez.Fonts.futura2XL);
        var futuraXSBI = loadResource(Rez.Fonts.futuraXSBI);
        var futura2SXBI = loadResource(Rez.Fonts.futura2XSBI);
        var iconFont = loadResource(Rez.Fonts.iconFont);

        // Load Distance/Steps property
        var displaySteps = Properties.getValue("DisplaySteps");

        // Load justification
        var justification = Graphics.TEXT_JUSTIFY_CENTER;

        // Get width and height for screen location calculations
        var percX = dc.getWidth();
        var percY = dc.getHeight();

        // Set label strings
        var hourLabel = getHourString();
        var minLabel = getMinString();
        var batteryLabel = getBatteryString();
        var distanceLabel = getDistanceLabel();
        var distanceIcon = "%";
        var heartLabel = getHeartRateString();
        var stepsLabel = getStepsString();
        var stepsIcon = "#";
        var tempLabel = getTempString();
        var tempSymbol = "°";

        // Set background
        dc.setColor(0x000000, 0x000000);
        dc.clear();

        // Set drawing settings for lines
        dc.setColor(lines, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.setAntiAlias(true);

        // Draw circle for heart rate
        dc.fillCircle(percX*0.22, percY*0.265, percX*0.08);

        // Draw circle for temperature
        dc.fillCircle(percX*0.22, percY*0.47, percX*0.08);

        // Draw circle for battery
        dc.fillCircle(percX*0.22, percY*0.67, percX*0.08);

        // Draw rectangle for mileage
        dc.fillRoundedRectangle(percX*0.155, percY*0.8, percX*0.65, percY*0.085, percX*0.04);

        // Time 
        dc.setColor(timeColor, transparent);
        dc.drawText(percX*0.6, percY*0.1, futura2XL, hourLabel, justification);
        dc.drawText(percX*0.6, percY*0.4, futura2XL, minLabel, justification);

        // Battery
        dc.setColor(batteryColor, transparent);
        dc.drawText(percX*0.22, percY*0.64, futura2SXBI, batteryLabel, justification);
        
        // Distance || Steps //
        dc.setColor(distanceColor, transparent);

        // Display distance
        if(!displaySteps)
        {
            dc.drawText(percX*0.57, percY*0.8, futuraXSBI, distanceLabel, justification);
            dc.drawText(percX*0.3, percY*0.805, iconFont, distanceIcon, justification);
        }
        
        // Display steps
        if(displaySteps)
        {
            dc.drawText(percX*0.57, percY*0.8, futuraXSBI, stepsLabel, justification);
            dc.drawText(percX*0.3, percY*0.805, iconFont, stepsIcon, justification);
        }

        // Heart Rate
        dc.setColor(heartColor, transparent);
        dc.drawText(percX*0.22, percY*0.24, futura2SXBI, heartLabel, justification);

        // Temperature
        dc.setColor(tempColor, transparent);
        dc.drawText(percX*0.22, percY*0.44, futura2SXBI, tempLabel, justification);
        dc.drawText(percX*0.265, percY*0.44, Graphics.FONT_SYSTEM_XTINY, tempSymbol, justification);
    }

    //---- Time Functions ----//
    // Function to get current time
    function getTime() as System.ClockTime 
    {
        var time = System.getClockTime();
        return time;
    }

    // Function to get hour as string
    function getHourString() as String
    {
        var hour = getTime().hour;

        if(!System.getDeviceSettings().is24Hour)
        {
            if(hour > 12)
            {
                hour = hour - 12;
            }
            if(hour == 0)
            {
                hour = hour + 12;
            }
        }
        var hourString = Lang.format(
            "$1$",
            [
                hour.format("%02d")
            ]
        );
        return hourString;
    }

    // Function to get minute string
    function getMinString() as String
    {
        var min = getTime().min;

        var minString = Lang.format(
            "$1$",
            [
                min.format("%02d")
            ]
        );
        return minString;
    }

    //---- Distance Functions ----//
    // Function to get start of week
    function getWeekStart() as Moment {
        var today = new Time.Moment(Time.today().value());
        var info = Gregorian.info(today, Time.FORMAT_SHORT);
        var firstDayOfWeek = 1;

        var settings = System.getDeviceSettings();
        if(settings has :firstDayOfWeek)
        {
            firstDayOfWeek = settings.firstDayOfWeek as Number;
        }

        var days = info.day_of_week as Number - firstDayOfWeek;
        // if(days < 0)
        // {
        //     days += 7;
        // }

        return today.subtract(new Time.Duration(days * 86400)) as Moment;
    }

    // Function to get weekly running distance (in meters)
    function getWeeklyRunningDistance() as Number {
        var dist = 0;
        if(UserProfile has :getUserActivityHistory)
        {
            var i = UserProfile.getUserActivityHistory();
            if(i != null || i == 0)
            {
                var next = i.next();
                var weekStart = getWeekStart();

                while(next != null)
                {
                    if(next.type == Activity.SPORT_RUNNING && next.distance != null)
                    {
                        if(next.startTime != null && weekStart.lessThan(next.startTime as Moment))
                        {
                            dist += next.distance as Number;
                        }
                    }
                    next = i.next();
                }
            }
        }
        return dist;
    }

    // Function to get distance in miles
    function getWeeklyRunDistanceMiles() as Float 
    {
        var dist = getWeeklyRunningDistance();
        // If distance is 0, return 0 miles
        var miles = 0;
        if(dist != null)
        {
            if(dist > 0)
            {
                miles = dist/1609.344;
            }
        }
        return miles;
    }

    // Function to get distance string
    function getDistanceLabel() as String
    {
        var milesString = getWeeklyRunDistanceMiles().format("%0.2f") + " mi";
        return milesString;
    }

    // Function to get steps as a number
    function getSteps() as Number or Null {
        return Toybox.ActivityMonitor.getInfo().steps;
    }

    // Function to get steps as a string 
    function getStepsString() as String {
        var steps = getSteps();
        if (steps == null) {
            return "0";
        }
        return getSteps().format("%d");
    }

    //---- Heart Rate Functions ----//
    // Function to get the heart rate as a number
    function getHeartRate() as Number 
    {
        var heartRateI = Toybox.ActivityMonitor.getHeartRateHistory(1, true);
        return heartRateI.next().heartRate;
    }

    // Function to get heart rate as a string 
    function getHeartRateString() as String 
    {
        var hr = getHeartRate();
        if(hr == 255 || hr == 0 || hr == null)
        {
            return "--";
        }
        else
        {
            return hr.format("%d");
        }
    }

    //---- Temperature Functions ----//
    // Function to get current temperature as string 
    function getTempString() as String 
    {
        var currConditions = Toybox.Weather.getCurrentConditions();
        var tempF = "--";
        if(currConditions != null && currConditions.temperature != null) {
            tempF = ((currConditions.temperature * 1.8) + 32).format("%d");
        }
        else {
            tempF = "--";
        }
        return tempF;
    }

    //---- Battery Functions ----//

    // Function to get the battery charging status as bool
    function getBatteryStatus() as Boolean
    {
        return Toybox.System.getSystemStats().charging;
    }
    
    // Function to get battery as float
    function getBattery() as Float 
    {
        return Toybox.System.getSystemStats().battery;
    }

    // Function to get battery percent as string
    function getBatteryString() as String
    {
        return getBattery().format("%d") + "%";
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }
}
