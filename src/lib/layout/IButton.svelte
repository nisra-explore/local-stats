<script>

import { base } from "$app/paths";

export let id;
export let place;
let card;
let row;

function checkMeta (value) {

	let value_dotted = value.replaceAll("[", ".").replaceAll("]", "");
	let props = value_dotted.split(".");

	let rtn_value = place.meta_data;

	for (let i = 0; i < props.length; i ++) {

		if (rtn_value.hasOwnProperty(props[i])) {
			rtn_value = rtn_value[props[i]]
			if (props[i] == "last_updated") {
				let numbers = rtn_value.split("-");
				rtn_value =  numbers[2] + "/" + numbers[1] + "/" + numbers[0];
			}
		}

	}

	return rtn_value;

}

function changeAria () {
	card.ariaHidden = !row.ariaExpanded;
}

let i_button_info = {

	// location: {
	// 		title: "About the area",
	// 		info: "Information about the area including its geographical hierarchy."
	// 	},
		


		// area: {
		// 	title: "Area",
		// 	info: "Area is measured in hectares (ha), it is rounded to the nearest whole number."
		// },

		popden: {
			title: "Population density",
			info: "Population density is the number of usual residents per square kilometer. A square kilometer is approximately equivalent to the floor space of 8 Titanics. It is rounded to 1 decimal place." +
			" <p class = 'pibutton'>Access data at: <a href='" + checkMeta("MYETotal[0].dataset_url") + "'>" + checkMeta("MYETotal[0].title") + "</a></p>" +
			"<p class = 'pibutton'>Last updated: " + checkMeta("MYETotal[0].last_updated") + "</p> "+
			 "<p class = 'pibutton'><a href='mailto:" + checkMeta("MYETotal[0].email") + "'>Email for more information</a> </p>"  ,

		},

		pop: {
			title: "Population",
			info: "Population is based on the number of usual residents at 30th June in the mid-year population estimates. " +
			" <p class = 'pibutton'>Access data at: <a href='" + checkMeta("MYETotal[0].dataset_url") + "'>" + checkMeta("MYETotal[0].title") + "</a></p>" +
			"<p class = 'pibutton'>Last updated: " + checkMeta("MYETotal[0].last_updated") + "</p> "+
			 "<p class = 'pibutton'><a href='mailto:" + checkMeta("MYETotal[0].email") + "'>Email for more information</a> </p>"  
		},

		generalhealth: {
			title: "General health",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"General health is a self-assessment of a person's general state of health. It is not " +
					"based over any specified period of time. <a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"},

		wellbeing: {
			title: "Personal wellbeing",
			info: "<p>Average Happiness score out of 10 for people aged 16+.  Average Life satisfaction score out of 10 for people aged 16+.<p>Average score out of 10 where 0 is ‘not at all’ and 10 is ‘completely’.</p></p>" +
				"<p class = 'pibutton'>Access data at: <a href='" + checkMeta("wellbeing[0].dataset_url") + "'>" + checkMeta("wellbeing[0].title") + "</a></p>"+
				"<p class = 'pibutton'>Last updated: " + checkMeta("wellbeing[0].last_updated") + "</p> "+
				"<p>Loneliness is the percentage of people aged 16+ who were lonely 'often/always' or 'some of the time'.</p>" +
				"<p class = 'pibutton'>Access data at: <a href='" + checkMeta("lonely[0].dataset_url") + "'>" + checkMeta("lonely[0].title") + "</a></p>"+
				"<p class = 'pibutton'>Last updated: " + checkMeta("lonely[0].last_updated") + "</p> "+
				"<p class = 'pibutton'><a href='mailto:" + checkMeta("lonely[0].email") + "'>Email for more information</a> </p>"   
				},

		lifeexpectancy: {
			title: "Life expectancy at birth",
			info:  "<p class = 'pibutton'>Life expectancy at birth is the average number of years a person born in the current period could expect to live if the current mortality patterns remain constant. "+
				" Further information on definitions is available on the <a href = 'https://www.health-ni.gov.uk/topics/dhssps-statistics-and-research/health-inequalities-statistics'>Health Inequalities webpage</a></p>" +
			"<p class = 'pibutton'>Access data at: <a href='" + checkMeta("LE[0].dataset_url") + "'>" + checkMeta("LE[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("LE[0].last_updated") + "</p> "+
				 	"<p class = 'pibutton'><a href='mailto:" + checkMeta("LE[0].email") + "'>Email for more information</a> </p>"  
		 		  
			},

			env_problem: {
			title: "Environmental problems",
			info: " <p class = 'pibutton'>Access data at: <a href='" + checkMeta("Env_problem[0].dataset_url") + "'>" + checkMeta("Env_problem[0].title") + "</a></p>" +
			"<p class = 'pibutton'>Last updated: " + checkMeta("Env_problem[0].last_updated") + "</p> "+
			 "<p class = 'pibutton'><a href='mailto:" + checkMeta("Env_problem[0].email") + "'>Email for more information</a> </p>"  },

		
			renewable: {
			title: "Household renewable energy systems",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"Renewable energy systems used to generate heat or energy for a household. Examples include: solar panels for electricity; solar panels for heating water; biomass and wind turbines." + 
			"<a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"},

	
	
			cars: {
			title: "Car or van availability",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"The number of cars or vans that are owned, or available for use, by members of a household. It includes company cars and vans that are available for private use." +
			"<a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"},

			active: {
			title: "Active and substainable travel",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("Env_active[0].dataset_url") + "'>" + checkMeta("Env_active[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("Env_active[0].last_updated") + "</p> "+
					"<p>Publications and associated documentation available at: <a href = 'https://www.infrastructure-ni.gov.uk/topics/statistics-and-research/travel-survey-tsni'>Travel Survey for Northern Ireland</a></p>"  +
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("Env_active[0].email") + "'>Email for more information</a> </p>" 
				},


			crime: {
			title: "Police recorded crimes",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("crime[0].dataset_url") + "'>" + checkMeta("crime[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("crime[0].last_updated") + "</p> "+
				 	"<p class = 'pibutton'><a href='mailto:" + checkMeta("crime[0].email") + "'>Email for more information</a> </p>"  
		 		  },

			burglary: {
			title: "Police recorded burglaries",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("crime[0].dataset_url") + "'>" + checkMeta("crime[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("crime[0].last_updated") + "</p> "+
				 	"<p class = 'pibutton'><a href='mailto:" + checkMeta("crime[0].email") + "'>Email for more information</a> </p>"  
		 		  },

		   crimetype: {
			title: "Types of crime",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("crime[0].dataset_url") + "'>" + checkMeta("crime[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("crime[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("crime[0].email") + "'>Email for more information</a> </p>"  +
				 	"<p class = 'pibutton'>Crime per 1,000 population based on mid-year population estimate</p>"  
					},

			crimeworry: {
			title: "Worry about crime",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("crimeworry[0].dataset_url") + "'>" + checkMeta("crimeworry[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("crimeworry[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("crimeworry[0].email") + "'>Email for more information</a> </p>"  
					},

			crimeperception: {
			title: "Views on antisocial behaviour",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("crimeperception[0].dataset_url") + "'>" + checkMeta("crimeperception[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("crimeperception[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("crimeperception[0].email") + "'>Email for more information</a> </p>"  
					},

					carers: {
			title: "Unpaid care giving",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"Unpaid care covers looking after giving help or support to anyone because they have long-term physical or "+
			"mental health conditions or illnesses, or problems related to old age. It does not include any activities as part of paid employment. All unpaid care statistics are restricted to persons aged 5 and over. "+
			"<a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"},

		hospitalactivity: {
			title: "Annual admissions to hospital",
			info:  "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("Admiss[0].dataset_url") + "'>" + checkMeta("Admiss[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("Admiss[0].last_updated") + "</p> "+
				 	"<p class = 'pibutton'><a href='mailto:" + checkMeta("Admiss[0].email") + "'>Email for more information</a> </p>"  
		 		  
				},

		primarycare: {
			title: "Primary care providers",
			info: "<p class = 'pibutton'>Access data at: " +
				  "<a href='" + checkMeta("GP[0].dataset_url") + "'>" + checkMeta("GP[0].title") + "</a>, " +
				  "<a href='" + checkMeta("DEN[0].dataset_url") + "'>" + checkMeta("DEN[0].title") + "</a> and " +
				  "<a href='" + checkMeta("DEN_REG[0].dataset_url") + "'>" + checkMeta("DEN_REG[0].title") + "</a></p>"
				},

			employmentrates: {
			title: "Work status of adults",
			info:  "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("LMS[0].dataset_url") + "'>" + checkMeta("LMS[0].title") + "</a></p>" + 
				  "<p class = 'pibutton'>Last updated: " + checkMeta("LMS[0].last_updated") + "</p> "+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("LMS[0].email") + "'>Email for more information</a> </p>"  +
		 		  "<p>Unemployed rates are based on those aged 16 and over, while both Employed and Inactive rates are based on those aged 16 to 64. Inactive includes students, early retirees, or people looking after a home, who are long-term sick or disabled. </p>"
				},


			employed: {
			title: "Work and wages",
			info:  "<p class = 'pibutton'>Access data on number employed at: <a href='" + checkMeta("LMS[0].dataset_url") + "'>" + checkMeta("LMS[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("LMS[0].last_updated") + "</p>"+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("LMS[0].email") + "'>Email for more information</a> </p>"  +
				  "<p >Access wages data at: <a href='" + checkMeta("ASHE_weekly[0].dataset_url") + "'>" + checkMeta("ASHE_weekly[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("ASHE_weekly[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("ASHE_weekly[0].email") + "'>Email for more information</a> </p>"  +
				  "<p>Median salary is the median gross weekly earnings for full-time employees.  The Median measures the amount earned by the average individual, that is the level of earnings at which half the population are above and half the population are below</p>"  
		 		 
		},


			wages: {
			title: "Average annual wage",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("ASHE[0].dataset_url") + "'>" + checkMeta("ASHE[0].title") + "</a></p>" + 
					"<p class = 'pibutton'>Last updated: " + checkMeta("ASHE[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("ASHE[0].email") + "'>Email for more information</a> </p>"  +
				  "<p>Median is the ..... </p>"
		},
		bres: {
			title: "Type of work",
			info:  "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("BRES[0].dataset_url") + "'>" + checkMeta("BRES[0].title") + "</a></p>"  +
			"<p class = 'pibutton'>Last updated: " + checkMeta("BRES[0].last_updated") + "</p>" +
			"<p class = 'pibutton'><a href='mailto:" + checkMeta("BRES[0].email") + "'>Email for more information</a> </p>"  
		 		 
				 
		},


			pensionagebenefits: {
			title: "State Pension",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("BS[0].dataset_url") + "'>" + checkMeta("BS[0].title") + "</a></p>"+
			"<p class = 'pibutton'>Last updated: " + checkMeta("BS[0].last_updated") + "</p> "+
			"<p class = 'pibutton'><a href='mailto:" + checkMeta("BS[0].email") + "'>Email for more information</a> </p>"  				
				},



			ucbenefits: {
			title: "Universal Credit",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("BS[0].dataset_url") + "'>" + checkMeta("BS[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("BS[0].last_updated") + "</p> "+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("BS[0].email") + "'>Email for more information</a> </p>"  
			}
						,
			pipbenefits: {
			title: "Personal Independence Payment",
			info: "<p class = 'pibutton'>Access data at:  <a href='" + checkMeta("BS[0].dataset_url") + "'>" + checkMeta("BS[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("BS[0].last_updated") + "</p> "+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("BS[0].email") + "'>Email for more information</a> </p>"  
					},

			enrollments: {
			title: "People in education",
			info: "<p class = 'pibutton'>Access data at: " +
				  "<a href='" + checkMeta("Primary[0].dataset_url") + "'>" + checkMeta("Primary[0].title") + "</a>, " +
				  "<a href='" + checkMeta("PostPrimary[0].dataset_url") + "'>" + checkMeta("PostPrimary[0].title") + "</a>,  " +
				  "<a href='" + checkMeta("FE[0].dataset_url") + "'>" + checkMeta("FE[0].title") + "</a> and " +
				  "<a href='" + checkMeta("HE[0].dataset_url") + "'>" + checkMeta("HE[0].title") + "</a></p>"},


			fsme: {
			title: "Pupils entitled to free school meals",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("Primary[0].dataset_url") + "'>" + checkMeta("Primary[0].title") + "</a> and "+
				  "<a href='" + checkMeta("PostPrimary[0].dataset_url") + "'>" + checkMeta("PostPrimary[0].title") + "</a></p>" +
				  "<p class = 'pibutton'>Last updated: " + checkMeta("Primary[0].last_updated") + "</p> "+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("Primary[0].email") + "'>Email for more information</a>.  Definitions are available on the <a href = 'https://www.education-ni.gov.uk/articles/school-enrolments-overview'>statistical publication page</a>. </p>" 
		
				  },


			teachers: {
			title: "School class size",
			info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("ClassSize[0].dataset_url") + "'>" + checkMeta("ClassSize[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("ClassSize[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("ClassSize[0].email") + "'>Email for more information</a> </p>"  
				},


			qualifications: {
			title: "Highest level of qualifications in the population",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
						"The highest level of qualification categories are as follows:" +
 					"<p>No qualifications;</p>" +
					 "<p>Level 1: 1 to 4 GCSEs, O levels, CSEs (any grades); 1 AS Level; NVQ level 1; or equivalent;</p>" +
					 "<p>Level 2: 5 or more GCSEs (A*-C or 9-4), O levels (passes) CSEs (grade 1); 1 A level, 2-3 AS Levels; NVQ level 2, BTEC General, City and Guilds Craft; or equivalent;</p>" +
					 "<p>Apprenticeship;</p>" +
 					"<p>Level 3: 2 or more A Levels, 4 or more AS Levels; NVQ Level 3, BTEC National, OND, ONC, City and Guilds Advanced Craft; or equivalent;</p>" +
 					"<p>Level 4 and above: Degree (BA, BSc), foundation degree, NVQ Level 4 and above, HND, HNC, professional qualifications (teaching or nursing, for example), or equivalent; and</p>" +
 					"<p>Other: Other qualifications, equivalent unknown.</p>" +
 					"<p>Highest level of qualification is derived from the question asking people aged 16 years and over to indicate all qualifications held. For qualifications gained outside Northern Ireland, respondents were directed to select the nearest equivalent.</p>"
				},


			attainment: {
			title: "GCSEs for school leavers",
			info: 
				  " <p class = 'pibutton'>Access data at: <a href='" + checkMeta("Attainment[0].dataset_url") + "'>" + checkMeta("Attainment[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("Attainment[0].last_updated") + "</p>"+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("Attainment[0].email") + "'>Email for more information</a> </p>"  
		},

		concern: {
			title: "Concern about the environment",
			info:  " <p class = 'pibutton'>Access data at: <a href='" + checkMeta("Env_concern[0].dataset_url") + "'>" + checkMeta("Env_concern[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("Env_concern[0].last_updated") + "</p>"+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("Env_concern[0].email") + "'>Email for more information</a> </p>"  
					},

			waste: {
			title: "Household waste",
			info:  " <p class = 'pibutton'>Access data at: <a href='" + checkMeta("Env_waste[0].dataset_url") + "'>" + checkMeta("Env_waste[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("Env_waste[0].last_updated") + "</p>"+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("Env_waste[0].email") + "'>Email for more information</a> </p>"  

					},


			ghg: {
			title: "Greenhouse gas",
			info:  " <p class = 'pibutton'>Access data at: <a href='" + checkMeta("Env_ghg[0].dataset_url") + "'>" + checkMeta("Env_ghg[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("Env_ghg[0].last_updated") + "</p>"+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("Env_ghg[0].email") + "'>Email for more information</a> </p>"  

					},



		empty: {
			title: "",
			info: ""
					},

			destination: {
				title: "Next steps for school leavers",
				info: 
				" <p class = 'pibutton'>Access data at: <a href='" + checkMeta("Destination[0].dataset_url") + "'>" + checkMeta("Destination[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("Destination[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("Destination[0].email") + "'>Email for more information</a> </p>"  ,
			},


			popchange: {
			title: "Population change",
			info: 
					" <p class = 'pibutton'>Access data at: <a href='" + checkMeta("PopChange[0].dataset_url") + "'>" + checkMeta("PopChange[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("PopChange[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("PopChange[0].email") + "'>Email for more information</a> </p>"  
		},

		broadage: {
			title: "Age",
			info: 
			 		" <p class = 'pibutton'> Age bands used at LGD, DEA and SDZ are different than those at the smaller data zones.  Access data at: <a href='" + checkMeta("BroadAge[0].dataset_url") + "'>" + checkMeta("BroadAge[0].title") + "</a></p>"+
			 		"<p class = 'pibutton'>Last updated: " + checkMeta("BroadAge[0].last_updated") + "</p> "+
					 "<p class = 'pibutton'><a href='mailto:" + checkMeta("BroadAge[0].email") + "'>Email for more information</a> </p>"  
			},
			
			age: {
			title: "Age",
			info: 
			 		"<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"A grouping of ages where a person’s age is their age at their last birthday on or prior to census day.  Age bands used at data zone are different than those at LGD, DEA and SDZ"+
			"<a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"
			},
				
		hhsize: {
			title: "Household size",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"The number of usual residents in the household.      <a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"},
			
		religion: {
			title: "Religion, Religion brought up in",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"The religious group the person belongs to or for people with no current religion their religious group of upbringing." +
				"People with no current religion and no religion of upbringing are labelled 'None'." + 
				"<a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"},
			
		language: {
			title: "Main language",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"Person's main language as declared in the Census." + 
					"Statistics for all language questions are restricted" + 
					"to persons aged 3 and over. <a" + 
					"href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'" + 
					"><strong>Statistical bulletins</strong></a>"},
			
			households: {
			title: "Households - box with numbers",
			info: "<p>From Census 2021 data - "+ "<a href='https://explore.nisra.gov.uk/area-explorer-2021/'><strong>Census Area Explorer</strong></a></p>"+
			"A household is either one person living alone or a group of people living at the same address " +
				  "who share cooking facilities and share a living room, sitting room or dining area. " +
				  "<a href='https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins'><strong>Statistical bulletins</strong></a>"
		},

		SEN: {
			title: "Special educational needs (SEN)",
			info: " <p class = 'pibutton'>Access data at:</p>" +
				  "<p class = 'pibutton'><a href='" + checkMeta("SEN[0].dataset_url") + "'>" + checkMeta("SEN[0].title") + "</a></p>"+
				  "<p class = 'pibutton'><a href='" + checkMeta("Primary[0].dataset_url") + "'>" + checkMeta("Primary[0].title") + "</a></p>"+
				  "<p class = 'pibutton'><a href='" + checkMeta("PostPrimary[0].dataset_url") + "'>" + checkMeta("PostPrimary[0].title") + "</a></p>"+
				  "<p class = 'pibutton'>Last updated: " + checkMeta("SEN[0].last_updated") + "</p>"+
				  "<p class = 'pibutton'><a href='mailto:" + checkMeta("SEN[0].email") + "'>Email for more information</a> </p>" + 
				  "<p class = 'pibutton'>These figures include SEN pupils enrolled in Special Education Schools, Primary Schools and Post-Primary Schools and include Statemented and Non Statemented pupils.  Definitions are available on the <a href = 'https://www.education-ni.gov.uk/articles/school-enrolments-overview'>statistical publication page</a>.</p>"
		},


		no_bus: {title: "Business and trade",
				info: 
				" <p class = 'pibutton'>Access data at: <a href='" + checkMeta("business[0].dataset_url") + "'>" + checkMeta("business[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("business[0].last_updated") + "</p> "+
					
					" <p class = 'pibutton'>Access data at: <a href='" + checkMeta("niets_sales[0].dataset_url") + "'>" + checkMeta("niets_sales[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("niets_sales[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("niets_sales[0].email") + "'>Email for more information</a> </p>"  


				},
		type_bus: {title: "Type of businesses",
				info: " <p class = 'pibutton'>Access data at: <a href='" + checkMeta("business[0].dataset_url") + "'>" + checkMeta("business[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("business[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("business[0].email") + "'>Email for more information</a> </p>"  },
		
		size_bus: {title: "Employees in businesses",
				info: " <p class = 'pibutton'>Access data at: <a href='" + checkMeta("businessband[0].dataset_url") + "'>" + checkMeta("businessband[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("businessband[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("businessband[0].email") + "'>Email for more information</a> </p>"  },

		sector: {title: "Selected business sectors",
				info: " <p class = 'pibutton'>Access farms data at: <a href='" + checkMeta("farms[0].dataset_url") + "'>" + checkMeta("farms[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("farms[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("farms[0].email") + "'>Email for more information</a> </p>"   + 
					" <p class = 'pibutton'>Access tourism jobs data at: <a href='" + checkMeta("tourism[0].dataset_url") + "'>" + checkMeta("tourism[0].title") + "</a></p>"+
					" <p class = 'pibutton'>Access tourism accomodation data at: <a href='" + checkMeta("tourism_estab[0].dataset_url") + "'>" + checkMeta("tourism_estab[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("tourism_estab[0].last_updated") + "</p> "+ 				
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("tourism[0].email") + "'>Email for more information</a> </p>"  
					
					},

		niets_sales: {title: "Places businesses sell to (sales partners)",
				info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("niets_sales[0].dataset_url") + "'>" + checkMeta("niets_sales[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("niets_sales[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("niets_sales[0].email") + "'>Email for more information</a> </p>"   
					
					},

					niets_purch: {title: "Places businesses buy from (purchases partners)",
				info: "<p class = 'pibutton'>Access data at: <a href='" + checkMeta("niets_sales[0].dataset_url") + "'>" + checkMeta("niets_sales[0].title") + "</a></p>"+
					"<p class = 'pibutton'>Last updated: " + checkMeta("niets_sales[0].last_updated") + "</p> "+
					"<p class = 'pibutton'><a href='mailto:" + checkMeta("niets_sales[0].email") + "'>Email for more information</a> </p>"   
					
					},


				}

</script>

<div class="row"
	style="display: flex; cursor: pointer;"
	data-bs-toggle="collapse"
	data-bs-target="#{id}-info"
	aria-expanded="false"
	aria-controls="{id}-info"
	bind:this={row}
>
	<div class="blocktitle" on:click={changeAria}>
		{i_button_info[id].title} <img class = "i-button" src = "{base}\img\i-button.svg" alt = "Information button">
	</div>
</div>
<div class="collapse" id="{id}-info">
    <div class="card card-body" aria-hidden="true" bind:this={card}>
        {@html i_button_info[id].info} 
    </div>
</div>

<style>
	.card {
		--bs-card-spacer-y: 0.1rem;
		--bs-card-spacer-x: 0.5rem;
		--bs-card-title-spacer-y: 0.5rem;
		--bs-card-border-width: 1px;
		--bs-card-border-color: var(--bs-border-color-translucent);
		--bs-card-border-radius: 0.375rem;
		--bs-card-box-shadow: ;
		--bs-card-inner-border-radius: calc(0.375rem - 1px);
		--bs-card-cap-padding-y: 0.5rem;
		--bs-card-cap-padding-x: 1rem;
		--bs-card-cap-bg: rgba(0, 0, 0, 0.03);
		--bs-card-cap-color: ;
		--bs-card-height: ;
		--bs-card-color: ;
		--bs-card-bg: #fff;
		--bs-card-img-overlay-padding: 1rem;
		--bs-card-group-margin: 0.75rem;
		position: relative;
		display: flex;
		flex-direction: column;
		min-width: 0;
		height: var(--bs-card-height);
		word-wrap: break-word;
		background-color: var(--bs-card-bg);
		background-clip: border-box;
		border: var(--bs-card-border-width) solid var(--bs-card-border-color);
		border-radius: var(--bs-card-border-radius);
	}

	.card-body {
		flex: 1 1 auto;
		padding: var(--bs-card-spacer-y) var(--bs-card-spacer-x);
		color: var(--bs-card-color);
		font-size: 10pt;
		margin-bottom: 5px;
	}

	.collapse:not(.show) {
		display: none;
	}
	.collapsing {
		height: 0;
		overflow: hidden;
		transition: height 0.35s ease;
	}

	.show {
		display: block !important;
	}
</style>