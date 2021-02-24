// vim: syntax=c

using Toybox.Application;

class Main extends Application.AppBase {
	function initialize() {
		AppBase.initialize();
	}

	function getInitialView() {
		return [new DataField()];
	}
}
