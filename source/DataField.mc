// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Math;
using Toybox.FitContributor;

class DataField extends WatchUi.SimpleDataField {
	const SOLAR_FIELD_ID = 0;
	hidden var solar_field;
	hidden var old_solar;

	function initialize() {
		SimpleDataField.initialize();
		label = "Solar";

		solar_field = createField(
				"solar",
				SOLAR_FIELD_ID,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"%"});
	}

	function compute(info) {
		var stats = System.getSystemStats();
		var new_solar = stats.solarIntensity;
		if (new_solar == null || new_solar < 0) {
			return "--";
		}
		if (new_solar != old_solar) {
			solar_field.setData(new_solar);
			old_solar = new_solar;
		}
		return stats.solarIntensity;
	}
}
