// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Math;
using Toybox.FitContributor;

class DataField extends WatchUi.SimpleDataField {
	const SOLAR_FIELD_ID = 0;
	const SOLAR_AVG_FIELD_ID = 1;
	hidden var solar_field;
	hidden var solar_avg_field;
	hidden var old_solar;

	hidden var solar_avg;
	hidden var solar_avg_count;

	function initialize() {
		SimpleDataField.initialize();
		label = "Solar";

		solar_field = createField(
				"solar",
				SOLAR_FIELD_ID,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"%"});
		solar_avg_field = createField(
				"solar_avg",
				SOLAR_AVG_FIELD_ID,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_SESSION, :units=>"%"});

		solar_avg = 0;
		solar_avg_count = 0;
	}

	function onTimerReset() {
		solar_avg = 0;
		solar_avg_count = 0;
	}

	function update_avg(info, val) {
		if (info.timerState != Activity.TIMER_STATE_ON) {
			return;
		}

		solar_avg_count++;
		solar_avg += val;
		solar_avg_field.setData(solar_avg / solar_avg_count);
	}

	function compute(info) {
		var stats = System.getSystemStats();
		var new_solar = stats.solarIntensity;
		if (new_solar == null) {
			return "---";
		} else if (new_solar < 0) {
			update_avg(info, 0);
			return "--";
		}

		update_avg(info, new_solar);

		if (new_solar != old_solar) {
			solar_field.setData(new_solar);
			old_solar = new_solar;
		}
		return stats.solarIntensity;
	}
}
