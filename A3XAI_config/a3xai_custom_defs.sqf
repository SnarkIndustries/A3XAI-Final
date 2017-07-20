/*
	A3XAI Custom Spawn Definitions File
	
	Instructions: 
	
		Generate custom spawns and blacklist areas using the included A3XAI Editor Tool (Inside the "Editor Tool" folder of the A3XAI download package).
		
		Instructions on how to use the Editor Tool are located on the A3XAI Wikia page: http://A3XAI.wikia.com/wiki/A3XAI_Editor_Tool
		
		In order for A3XAI to load this file on startup, you must set in @A3XAI/A3XAI_config/config.cpp under the "A3XAI Settings" section:
		
			loadCustomFile = 1;

//----------------------------Add your custom spawn and dynamic area blacklist definitions below this line ----------------------------*/

call {
	if (worldName == "taviana") exitWith {
		["SectorB_1",[22246.4,19894.3,0.00143862],100,4,3,true,600] call A3XAI_createCustomInfantryQueue;
		["SectorB_2",[22353.9,19542.2,0.00143862],200,4,3,true,600] call A3XAI_createCustomInfantryQueue;
		["SectorB_3",[22500.5,20066,0.00143862],100,4,3,true,600] call A3XAI_createCustomInfantryQueue;
		["SectorB_4",[22767.7,19846.5,0.00143862],200,4,3,true,600] call A3XAI_createCustomInfantryQueue;
		["SectorB_5",[22880.7,19340.1,0.00143862],200,4,3,true,600] call A3XAI_createCustomInfantryQueue;
		["SectorB_6",[22448.9,19484.1,0.00143862],100,4,3,true,600] call A3XAI_createCustomInfantryQueue;
		["VishkovMilitary",[11193.4,15783.1,0.00144196],200,3,2,true,600] call A3XAI_createCustomInfantryQueue;
		["VishkovCivilian",[11429.7,15904.4,0.00144196],200,3,1,true,600] call A3XAI_createCustomInfantryQueue;
		["DubravkaCivilian",[11781.3,15581.2,0.00144196],200,3,1,true,600] call A3XAI_createCustomInfantryQueue;
		["StariGradCivilian",[11297.1,15430.2,0.00144196],175,3,1,true,600] call A3XAI_createCustomInfantryQueue;
		["BoriMilitary",[11670.5,14961.6,0.00144196],200,3,2,true,600] call A3XAI_createCustomInfantryQueue;
		["NinaMilitary",[12455.3,14983.6,0.00144196],175,3,2,true,600] call A3XAI_createCustomInfantryQueue;
	};
	if (worldName == "namalsk") exitWith {
		A3XAI_manualStaticSpawnLocations = [
			[4157.5698, 6636.252],
			[3558.3298, 6664.4048],
			[3940.0078, 7536.5967],
			[4976.6655, 6619.644, 42.068932],
			[4845.8853, 6201.1484, 0],
			[4081.9597, 9224.0859, 2.600769],
			[4690.1934, 8916.7041, 5.2387733],
			[5781.0708, 9809.7734, -7.6293945e-006],
			[6308.022, 9307.7139],
			[5807.0181, 8676.9521, 12.870121],
			[7293.3511, 7967.5581, 3.7465744],
			[7694.8877, 7602.1001, 1.2397766e-005],
			[7046.0806, 5808.7622],
			[5986.1616, 6641.3848, -1.1444092e-005],
			[4947.3247, 8158.6709, -3.8146973e-006],
			[8199.6846, 10729.502],
			[4829.1992, 10839.983, 2.8610229e-006],
			[4498.3965, 11127.151, -1.2159348e-005],
			[4407.7451, 10748.695],
			[6784.3296, 11291.731, 5.5010681],
			[7668.0474, 8760.8672, 12.067543],
			[3173.5461, 7504.5532],
			[6943.7725, 11424.083],
			[5777.3901, 10784.223, 0],
			[6719.9434, 11113.122, 20.099487]
		];
	};
};

