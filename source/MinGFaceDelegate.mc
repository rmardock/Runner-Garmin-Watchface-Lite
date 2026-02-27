import Toybox.System;
import Toybox.Application;
import Toybox.WatchUi;

class MinGFaceDelegate extends WatchUi.WatchFaceDelegate {

    // Initialize
    function initialize()
    {
        WatchFaceDelegate.initialize();
    }

    // When touch screen is tapped and held
    function onPress(tapEvent)
    {
        // Update display steps property
        var displaySteps = Properties.getValue("DisplaySteps");
        if(displaySteps)
        {
            Properties.setValue("DisplaySteps", false);
        }
        if(!displaySteps)
        {
            Properties.setValue("DisplaySteps", true);
        }
        return true;
    }
}