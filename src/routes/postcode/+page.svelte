<script>
	import Section from "$lib/layout/Section.svelte";
	import { base } from "$app/paths";
	import { app_inputs} from "$lib/config";

	let searchInput;
	let resultTable;

	function normalisePostcode (postcode) {
		// Remove all spaces from the postcode and convert to uppercase
		return postcode.replace(/\s/g, "").toUpperCase();
	}

	function search () {
			const searchTerm = normalisePostcode(searchInput.value);
			
			if (searchTerm === "") {
				alert("Please enter a postcode.");
				return;
			}

			fetch("https://raw.githubusercontent.com/nisra-explore/local-stats/main/search_data/CPD_LIGHT_JULY_2024.csv")
				.then((response) => response.text())
				.then((data) => {
					const rows = data.split("\n");
					let found = false;

					// Prepare list HTML
					let pHTML = "<p>";
					let listHTML = "<ul>";
					let listHTML2 = "<ul>";

					rows.forEach((row) => {
						const columns = row.split(",");
						const postcode = normalisePostcode(columns[0]);

						if (postcode === searchTerm) {
							// Extract specific columns (lgd and ward)
							const lgd2014 = columns[4].trim();
							const LGD2014NAME = columns[5].trim();
							const WARD2014 = columns[6].trim();
							const WARD2014NAME = columns[7].trim();
							const DEA2014 = columns[8].trim();
							const DEA2014NAME = columns[9].trim();
							const AA2008 = columns[10].trim();
							const AA2008NAME = columns[11].trim();
							const AA2024NAME = columns[23].trim();
							const HSCTNAME = columns[17].trim();
							const DZ2021 = columns[18].trim();
							const DZ2021_name = columns[19].trim();
							const SDZ2021 = columns[20].trim();
							const SDZ2021_name = columns[21].trim();
							const SETTLEMENT15 = columns[30].trim();
							const SETTLEMENT15_URBAN_RURAL = columns[31].trim();
							
							pHTML += `<strong>Postcode:</strong> ${postcode.slice(0, -3)} ${postcode.substr(-3)}`;

							listHTML += `<li><strong>Local Government District:</strong> <a href="${base}/${lgd2014}" target="_blank">${LGD2014NAME}</a></li>
										 <li><strong>District Electoral Area:</strong> <a href="${base}/${DEA2014}" target="_blank">${DEA2014NAME}</a></li>
										 <li><strong>Super Data Zone:</strong> <a href="${base}/${SDZ2021}" target="_blank">${SDZ2021_name}</a></li>
										 <li><strong>Data Zone:</strong> <a href="${base}/${DZ2021}" target="_blank">${DZ2021_name}</a></li>`;
										

							listHTML2 += `<li><strong>Urban / Rural:</strong> ${SETTLEMENT15_URBAN_RURAL}</li>
										  <li><strong>Settlement:</strong> ${SETTLEMENT15}</li>
										  <li><strong>Health and Social Care Trust:</strong> ${HSCTNAME}</li>
										  <li><strong>Assembly Area Name (2008):</strong> ${AA2008NAME}</li>
										  <li><strong>Assembly Area Name (2024):</strong> ${AA2024NAME}</li>
										  <li><strong>Ward Name:</strong> ${WARD2014NAME}</li>`;

							found = true;
						}
					});

					pHTML += "</p>";
					listHTML += "</ul>";
					listHTML2 += "</ul>";

					if (!found) {
						resultTable.innerHTML =
							"Postcode not found.";
					} else {
						resultTable.innerHTML =
							pHTML +
							"<p>Geographies in Northern Ireland Local Statistics Explorer</p>" +
							listHTML +
							"<p>Geographies not in Northern Ireland Local Statistics Explorer</p>" +
							listHTML2;
					}
				})
				.catch((error) => {
					console.error("Error fetching data:", error);
					alert("Error fetching data. Please try again.");
				});
		}	

</script>

<nav>
	<a href="{base}/">Home</a>
</nav>

<Section column="wide">
	<body>
		<div class="row">
			<div class="container div-grey-box">
				<h2>Enter your postcode to find its location</h2>
				<form on:submit|preventDefault={search}>
				<input
					type="text"
					placeholder="Enter postcode..."
					bind:this={searchInput}
				>
				<button on:click={search}><img src = "{base}/img/search.svg" alt = "Search button" width="40px"></button>
				</form>
				<div bind:this={resultTable}></div>
			</div>
		</div>
	</body>

	<style>

		form {
			position: relative;
			display: inline-block;
			width: 100%;
			margin-top: 15px;
		}

		.container {
			max-width: 600px;
			margin: 0 auto;
			padding: 20px;
		}

		h2 {
			text-align: left;
			color: #333;
			font-size: 1.5em;
			line-height: 1.3;
			margin: 0px 
		}

		input[type="text"] {
			width: 100%;
			padding: 10px 40px 10px 10px;
			margin-bottom: 10px;
			border: 2px solid #00205b !important;
			border-radius: 0px;
			background-color: #f5f5f6;
			color: #00205b;
		}

		input[type="text"]:focus-visible {
			border: 2px solid #00205b;
			border-radius: 0px;
		}

		button {
			background-color: #00205b;
			background-repeat: no-repeat;
			border-radius: 0px;
			color: #fff;
			border: none;
			cursor: pointer;
			position: absolute;
			top: 0;
			right: 0;
			padding: 0px;
			width: 40px;
			height: 46px;
		}

		button:focus {
			background-color: #00205b;
		}


		#result {
			margin-top: 20px;
			padding: 10px;
			border: 1px solid #ddd;
			border-radius: 4px;
		}
	</style>
</Section>
