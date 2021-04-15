// Define the default location of webservices

function getDefaultServicesPrefix() {
	var servername = "/arxlab/_inclds/experiments/chem/asp";
	var webapp = "/jchemProxy.asp?searchtype=";
	return servername + webapp;
}

function getDefaultServices() {
	var base = getDefaultServicesPrefix();
	var services = {
			"clean2dws" : base + "util/convert/clean",
			"clean3dws" : base + "util/convert/clean",
			"molconvertws" : base + "util/calculate/molExport",
			"stereoinfows" : base + "util/calculate/cipStereoInfo",
			"reactionconvertws" : base + "util/calculate/reactionExport",
			"hydrogenizews" : base + "util/convert/hydrogenizer",
			"automapperws" : base + "util/convert/reactionConverter",
			"aromatizews" : base + "util/calculate/molExport"
	};
	return services;
}