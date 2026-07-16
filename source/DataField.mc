// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Math;
using Toybox.FitContributor;

class DataField extends WatchUi.SimpleDataField {
	const SOLAR_FIELD_ID = 0;
	const SOLAR_AVG_FIELD_ID = 1;
	const BATT_FIELD_ID = 2;
	hidden var solar_field;
	hidden var solar_avg_field;
	hidden var batt_field;

	hidden var solar_avg;
	hidden var solar_avg_count;
	
	hidden var last_batt_x100;
	hidden var last_solar;

	function initialize() {
		SimpleDataField.initialize();
		label = "SOLAR";

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
		batt_field = createField(
				"battery_pct", BATT_FIELD_ID,
				FitContributor.DATA_TYPE_FLOAT,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"%"});

		solar_avg = 0;
		solar_avg_count = 0;

		last_batt_x100 = -1;
		last_solar = -1;
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
			solar = 0;
		}

		if (solar != last_solar) {
			solar_field.setData(solar);
			last_solar = solar;
		}
		update_avg(info, solar);

		var batt_x100 = Math.round(stats.battery * 100).toNumber();
		if (batt_x100 != last_batt_x100) {
			batt_field.setData(stats.battery);
			last_batt_x100 = batt_x100;
		}

		return solar;
	}
}
