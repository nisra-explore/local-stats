// CORE CONFIG
export const themes = {
	'light': {
		'name': 'light',
		'text': '#222',
		'muted': '#777',
		'pale': '#f0f0f0',
		'background': '#fff'
	},
	'dark': {
		'name': 'dark',
		'text': '#fff',
		'muted': '#bbb',
		'pale': '#333',
		'background': '#222'
	}
};

export const app_inputs = {
//	search_data: 'https://datavis.nisra.gov.uk/techlab/yalcbs/places_dz_extra.csv',
	search_data: 'https://raw.githubusercontent.com/nisra-explore/local-stats/main/search_data/places_dz_full_postcode_JULY2024.csv',
	//search_data: '/search_data/places_dz_full_postcode.csv',
	//postcode_data: '/search_data/cpd_light_with_lat_long_2.csv',
	postcode_data: 'https://raw.githubusercontent.com/nisra-explore/local-stats/main/search_data/CPD_LIGHT_JULY_2024.csv',
	// app_json_data: 'https://datavis.nisra.gov.uk/techlab/yalcbs/',
//	 app_json_data: '/data_jsons_dea_20240408/',
	//app_json_data: '/alternative_jsons/',
	 app_json_data: "https://raw.githubusercontent.com/nisra-explore/local-stats/main/github_action_jsons/",
	//app_json_data: "/jsons_nogroup/",
	base: 'https://explore.nisra.gov.uk/local-stats/'
};

export const geog_types = {
	dz: {name: 'Data Zone', pl: 'Data Zones'},
	sdz: {name: 'Super Data Zone', pl: 'Super Data Zones'},
//	ward: { name: 'Electoral Ward', pl: 'Ward' },

	dea: {name: 'Electoral Area', pl: 'Electoral Areas'},
	town: {name: 'settlement', pl: 'settlements'},
	lgd: {name: 'Council', pl: 'Councils'},
	postcode: {name: 'postcode', pl: 'postcodes'},
	ctry: { name: 'Country', pl: 'Countries' },
	ni: { name: 'Country', pl: 'Countries' }
};

export const topics = {
	age: [
		{ category: 'a0to14', label: '0-14' },
		{ category: 'a15to39', label: '15-39' },
		{ category: 'a40to64', label: '40-64' },
		{ category: 'a65plus', label: '65+' }
	],
	// highest_level_of_qualifications : [
	// 	{ category: "no_qualifications", label: 'No qualifications' },
	// 	{ category: "level_1_qualifications", label: '1 to 4 GCSEs' },
	// 	{ category: "level_2_qualifications", label: '5 or more GCSEs' },
	// 	{ category: "apprenticeship", label: 'Apprenticeship' },
	// 	{ category: "level_3_qualifications", label: '2 or more A Levels' },
	// 	{ category: "level_4_qualifications_and_above", label: 'Degree (BA, BSc) and above' },
	// 	{ category: "other_qualifications", label: 'Other' }
	// 	  ],


		  highest_level_of_qualifications : [
			{ category: "no_qualifications", label: 'No qualifications' },
			{ category: "level_1_qualifications", label: 'Level 1' },
			{ category: "level_2_qualifications", label: 'Level 2' },
			{ category: "apprenticeship", label: 'Apprenticeship' },
			{ category: "level_3_qualifications", label: 'Level 3' },
			{ category: "level_4_qualifications_and_above", label: 'Level 4 and above ' },
			{ category: "other_qualifications", label: 'Other' }
			  ],

	religion_or_religion_brought_up_in: [
		{ category: 'catholic', label: 'Catholic' },
		{ category: 'protestant_and_other_christian_including_christian_related', label: 'Protestant & other Christian religions' },
		{ category: 'other_religions', label: 'Other religions' },
		{ category: 'none', label: 'None' }
	],
	hh_size: [
		{ category: 'one_person', label: '1 person' },
		{ category: 'two_people', label: '2 people' },
		{ category: 'three_people', label: '3 people' },
		{ category: 'four_people', label: '4 people' },
		{ category: 'five_people', label: '5 or more people' }
	],
	general_health: [
		{ category: 'very_good', label: 'Very good' },
		{ category: 'good', label: 'Good' },
		{ category: 'fair', label: 'Fair' },
		{ category: 'bad', label: 'Bad' },
		{ category: 'very_bad', label: 'Very bad' }
	],
	provision_care: [
		{ category: 'no_care', label: 'Provides no unpaid care' },
		{ category: 'a1to19_hours', label: '1-19 hours' },
		{ category: 'a20to49_hours', label: '20-49 hours' },
		{ category: 'a50plus_hours', label: '50+ hours' }
	],
	mainlang: [
		{ category: 'english', label: 'English' },
		{ category: 'other_languages', label: 'Other languages' }
	],
	cob: [
		{ category: 'northern_ireland', label: 'Northern Ireland' },
		{ category: 'england', label: 'England' },
		{ category: 'scotland', label: 'Scotland' },
/* 		{ category: 'wales', label: 'Wales' },
		{ category: 'republic_of_ireland', label: 'Republic of Ireland' },
 */		{ category: 'other_cob', label: 'Other country of birth' }
	],

	car_or_van: [
		{ category: 'none', label: 'No cars or vans' },
		{ category: 'one', label: '1 car or van' },
		{ category: 'two', label: '2 cars or vans' },
		{ category: 'three', label: '3 cars or vans' },
		{ category: 'four', label: '4 cars or vans' },
		{ category: 'five_or_more', label: '5 or more cars or vans' }
	],

	renewable_energy: [
		{ category: 'no_renewable', label: 'No renewable energy systems' },
		{ category: 'any_renewable', label: 'Any renewable energy systems' }
	],


	BRES: [

		{ category: 'Construction', label: 'Construction' },
		{ category: 'Manufacturing', label: 'Manufacturing' },
		{ category: 'Services', label: 'Services' }	,
		{ category: 'Other', label: 'Other' }	
			],



	LMS: [

//		{ category: 'EMPN', label: 'Employed'},
		{ category: 'EMPR', label: 'Employed' },
		{ category: 'UNEMPR', label: 'Unemployed' }	,
		{ category: 'INACTR', label: 'Inactive' }	
			
	],


	
	Destination: [

		{ category: 'destHEpct', label: 'Higher Education' },
		{ category: 'destFEpct', label: 'Further Education' }	,
		{ category: 'destEmploypct', label: 'Employment' },
		{ category: 'destTrainpct', label: 'Training' },
		{ category: 'destUnempUnkpct', label: 'Unemployed or unknown' }
			
			
	],

	BroadAge: [
		{ category: 'Age 0-15', label: '0-15' },
		{ category: 'Age 16-39', label: '16-39' },
		{ category: 'Age 40-64', label: '40-64' },
		{ category: 'Age 65+', label: '65+' }
	],

	age: [
		{ category: 'a0to14', label: '0-14' },
		{ category: 'a15to39', label: '15-39' },
		{ category: 'a40to64', label: '40-64' },
		{ category: 'a65plus', label: '65+' }
	],
	
	Env_waste: [
		{ category: 'LACMWR', label: 'Recycled' },
		{ category: 'LACMWL', label: 'Landfill' },
		{ category: 'LACMWER', label: 'Energy Recovery' }
	],

	Env_concern: [
		{ category: 'CONCERNENVI', label: 'Concerned' },
		{ category: 'NOTCONCERNENVI', label: 'Not concerned' }
		],

		businessband: [
			{ category: 'E1', label: '0 employees' },
			{ category: 'E2', label: '1-9  employees' },
			{ category: 'E3', label: '10-49  employees' },
			{ category: 'E4', label: '50-249  employees' },
			{ category: 'E5', label: '250+  employees' }
			
			],


			businesstype: [
				{ category: 'agr', label: 'Agriculture' },
				{ category: 'cons', label: 'Production' },
				{ category: 'prod', label: 'Construction' },
				{ category: 'serv', label: 'Services' }
				
				],

			crime: [
				{ category: 'person', label: 'Violence against the person' },
				{ category: 'sexual', label: 'Sexual offences' },
				{ category: 'robbery', label: 'Robbery' },
				{ category: 'theft_burglary', label: 'Theft offences - Burglary ' },
				{ category: 'theft', label: 'Theft offences ' },
				{ category: 'criminal', label: 'Criminal damage' },
				{ category: 'other', label: 'Other crimes against society' }
				
				], 
			
				
				 
				
				

				// crime: [
				// 	{ category: 'person', label: 'Violence against the person, sexual offences & robbery' },
				// 	{ category: 'btcd', label: 'Burglary, theft & criminal damage' },
				// 	{ category: 'other', label: 'Other crimes against society' }
					
				// 	],

			niets_sales: [
				{ category: 'NI', label: 'Northern Ireland' },
				{ category: 'GB', label: 'Great Britain' },
				{ category: 'IE', label: 'Republic of Ireland' },
				{ category: 'REU', label: 'Rest of EU' },
				{ category: 'ROW', label: 'Rest of world' }
				
				
				],
				niets_purch: [
					{ category: 'NI', label: 'Northern Ireland' },
					{ category: 'GB', label: 'Great Britain' },
					{ category: 'IE', label: 'Republic of Ireland' },
					{ category: 'REU', label: 'Rest of EU' },
					{ category: 'ROW', label: 'Rest of world' }
					
					
					],
	

};



export const mapStyle = 'https://raw.githubusercontent.com/nisra-explore/map_tiles/main/basemap_styles/style-omt.json';


export const mapSources = {
	lgd: {
		id: 'lgd',
		promoteId: 'lgd_code',
		type: 'vector',
		url: 'https://raw.githubusercontent.com/nisra-explore/map_tiles/main/lgd2014/{z}/{x}/{y}.pbf',
		maxzoom: 12
	},
	dea: {
		id: 'dea',
		promoteId: 'dea_code',
		type: 'vector',
		url: 'https://raw.githubusercontent.com/nisra-explore/map_tiles/main/dea_2014/{z}/{x}/{y}.pbf',
		minzoom: 6,
		maxzoom: 12
	},
	sdz: {
		id: 'sdz',
		promoteId: 'sdz_code',
		type: 'vector',
		url: 'https://raw.githubusercontent.com/nisra-explore/map_tiles/main/sdz_2021/{z}/{x}/{y}.pbf',
//		url: '/data/map_tiles/soa21/{z}/{x}/{y}.pbf',
		minzoom: 6,
		maxzoom: 12
	},
	dz: {
		id: 'dz',
		promoteId: 'dz_code',
		type: 'vector',
		url: 'https://raw.githubusercontent.com/nisra-explore/map_tiles/main/dz_2021/{z}/{x}/{y}.pbf',
//		url: '/data/map_tiles/sa/{z}/{x}/{y}.pbf',
 		minzoom: 6,
		maxzoom: 12, 
	}
	// ,
	// ward: {
	// 	id: 'ward',
	// 	promoteId: 'ward_Code',
	// 	type: 'vector',
	// 	url: 'https://raw.githubusercontent.com/nisra-explore/map_tiles/main/ward2014/{z}/{x}/{y}.pbf',
	// 	minzoom: 6,
	// 	maxzoom: 12
	//} 
};

export const mapLayers = {

	lgd: {
		source: 'lgd',
		sourceLayer: 'LGD2014_clipped',
		code: 'lgd_code',
		name: 'lgd_name'	},
	dea: {
		source: 'dea',
		sourceLayer: 'DEA2014_clipped',
		code: 'dea_code',
		name: 'dea_name'},
	sdz: {
		source: 'sdz',
		sourceLayer: 'SDZ2021_clipped',
		code: 'sdz_code',
		name: 'sdz_name'
	},
	dz: {
		source: 'dz',
		sourceLayer: 'DZ2021_clipped',
		code: 'dz_code',
		name: 'dz_name', 
		
	}
	// , 

	// ward: {
	// 	source: 'ward',
	// 	sourceLayer: 'WARD2014_clipped',
	// 	code: 'ward_code',
	// 	name: 'ward_name'
	// } 

};


export const mapPaint = {
	fill: {
		'fill-color': 'rgba(255,255,255,0)',
		'fill-opacity': 0
	},
	line: {
		'line-color': 'rgba(255,255,255,0)',
		'line-width': 1,
		'line-opacity': 0
	},
	'fill-active': {
		'fill-color': [
			'case',
			['==', ['feature-state', 'selected'], true], 'rgba(255,255,255,0)',
			'grey'
		],
		'fill-opacity': [
			'case',
			['==', ['feature-state', 'hovered'], true], 0.3,
			['!=', ['feature-state', 'selected'], true], 0.1,
			0
		]
	},
	'fill-self': {
		'fill-color': [
			'case',
			['==', ['feature-state', 'selected'], true], 'rgb(56,120,197)',
			'grey'
		],
		'fill-opacity': [
			'case',
			['==', ['feature-state', 'hovered'], true], 0.3,
			0.1
		]
	},
	'fill-child': {
		'fill-color': [
			'case',
			['==', ['feature-state', 'highlighted'], true], 'rgb(56,120,197)',
			'rgba(255,255,255,0)'
		],
		'fill-opacity': [
			'case',
			['==', ['feature-state', 'hovered'], true], 0.3,
			['==', ['feature-state', 'highlighted'], true], 0.1,
			0
		]
	},
	'line-active': {
		'line-color': [
			'case',
			['==', ['feature-state', 'selected'], true], 'rgb(56,120,197)',
			'grey'
		],
		'line-width': 2,
		'line-opacity': 1
	},
	'line-self': {
		'line-color': 'rgb(56,120,197)',
		'line-width': 2,
		'line-opacity': [
			'case',
			['==', ['feature-state', 'selected'], true], 1,
			0
		]
	},
	'line-child': {
		'line-color': 'rgb(56,120,197)',
		'line-width': 1,
		'line-opacity': [
			'case',
			['==', ['feature-state', 'highlighted'], true], 1,
			0
		]
	}
};
