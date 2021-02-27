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
				FitContributor.DATA_TYPE_FLOAT,
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
		solar_avg_field.setData(solar_avg.toFloat() / solar_avg_count);
	}

	function compute(info) {
		var stats = System.getSystemStats();
		var solar = stats.solarIntensity;
		if (solar == null) {
			return "---";
		} else if (solar < 0) {
			solar_field.setData(0);
			update_avg(info, 0);
			return "--";
		}

		solar_field.setData(solar);
		update_avg(info, solar);

		return stats.solarIntensity;
	}
}
