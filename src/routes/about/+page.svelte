<script>
	import Section from "$lib/layout/Section.svelte";
	import { base } from "$app/paths";

	export let data;

	function formatLastUpdated(value) {
		if (!value) return value;
		const numbers = String(value).split("-");
		return numbers.length === 3
			? `${numbers[2]}/${numbers[1]}/${numbers[0]}`
			: value;
	}
</script>




<Section column="wide">
	<a  href='{base}/'>Home</a>

	<div class="row">


		<h1>About the Northern Ireland Local Statistics Explorer</h1>


		<h2>What is the app?</h2>
		<p>The Northern Ireland Local Statistics Explorer provides a high-level overview of key statistics for Northern Ireland and its local areas.</p>

		<p>The interactive application brings together a selection of statistical information published by the Northern Ireland Statistics and Research Agency (NISRA), making it easier to explore and compare statistics for different areas.</p>

		<h2>Features</h2>
		<ul> 
			<li><strong>Comprehensive data coverage:</strong> Explore a selection of statistics covering different aspects of life in Northern Ireland, including population, the economy, education, health and more.</li>
			<li><strong>User-friendly interface:</strong> Navigate and explore statistical information through an intuitive interface designed for a wide range of users.</li>
			<li><strong>Data downloads:</strong> Follow links to source datasets to download data for further analysis.</li>
			<li><strong>Supporting information:</strong> Use the &lsquo;i&rsquo; button beside each statistic to view definitions, data sources, contact details and the date the statistic was last updated.</li>
			<li><strong>More statistics:</strong> Use the More statistics section within each topic to find related statistics that are available elsewhere.</li>

		</ul>
		
		<h2>Sources of data</h2>
		
		<p>Data in the Local Statistics Explorer is sourced from the <a href="https://data.nisra.gov.uk">NISRA Data Portal</a> and the <a href="https://explore.nisra.gov.uk/area-explorer-2021/">Census Area Explorer</a>.</p>
		
		<h3>The NISRA Data Portal</h3>
		<p>The <a href="https://data.nisra.gov.uk">NISRA Data Portal</a> is the central access point for official statistics produced by NISRA. It brings together a wide range of datasets covering Northern Ireland's population, society and economy.  </p>
		<p>The Data Portal is continually refreshed with new and updated datasets from across the Northern Ireland Civil Service (NICS) and wider public sector.  
			Users can search and filter datasets, create tables, explore data through interactive charts and maps, save queries and favourite datasets, and download data in a range of formats, including XLSX, CSV, JSON-stat and PX. Data can also be accessed programmatically using API queries.</p>
		
		<p><a href = "https://www.nisra.gov.uk/nisra-data-portal-faqs-and-training-materials">Training Materials</a> including user guidance and instructional videos, are available to help you use the Data Portal.  </p>
		<p>You can register your interest in online training or request further help by emailing <a href="mailto:info@nisra.gov.uk">info@nisra.gov.uk</a>. </p>


		<h3>The Census Area Explorer</h3>
		<p>The census takes place once every 10 years and provides the most accurate estimate of the people and households in Northern Ireland. The most recent census took place on 21 March 2021.</p>
		<p>You can explore Census 2021 results using the Census Area Explorer, the NISRA website and the Flexible Table Builder.</p>	
		
		<p>The <a href="https://explore.nisra.gov.uk/area-explorer-2021/">Census Area Explorer</a> is an interactive tool that allows you to select an area and explore Census 2021 results, including comparisons with Northern Ireland and Census 2011.</p>
		<p>The <a href="https://www.nisra.gov.uk/statistics/census">NISRA website</a> provides Census news, results, publications and information about previous censuses.</p>
		<p>The <a href="https://build.nisra.gov.uk/en/">Flexible Table Builder</a> allows you to build customised Census 2021 tables or search for and customise ready-made tables.</p>

		<h3>Geographical Levels</h3>
		<p>The Local Statistics Explorer provides statistics for several geographical levels.</p>

		<table>
			<thead>
			  <tr>
				<th>Geography Level</th>
				<th>Count</th>
			  </tr>
			</thead>
			<tbody>
			  <tr>
				<td>Northern Ireland</td>
				<td>—</td>
			  </tr>
			  <tr>
				<td>Local Government District (LGD2014), also called councils.</td>
				<td>11</td>
			  </tr>
			  <tr>
				<td>District Electoral Area (DEA2014), called electoral areas in this web application</td>
				<td>80</td>
			  </tr>
			  <tr>
				<td>Super Data Zone (SDZ2021)</td>
				<td>850</td>
			  </tr>
			  <tr>
				<td>Data Zone (DZ2021)</td>
				<td>3,780</td>
			  </tr>
			</tbody>
		  </table>


		<h4>Administrative  geographies</h4>
		<p>Northern Ireland is divided into 11 Local Government Districts (LGD), also known as councils. The 11 new Districts became operational in April 2015. </p>
		<p>Further information is available in the <a href='https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/11DC_Guidance_1_0.pdf'>LGD 2014 information paper</a> produced by NISRA.</p>
		<p>Each LGD is subdivided into district electoral areas.</p>
		<p>District Electoral Areas (DEAs) are the units made up of groups of local government wards, usually around 5 to 7, which are used for the purpose of administration of local government elections and are also used to help District Councils develop strategy for service delivery.</p> 

		<h4>Statistical geographies</h4>
		<p>Data Zones and Super Data Zones are statistical output geographies created to support the publication of local-level Census 2021 statistics.</p>
		<p>There are 3,780 Data Zones (DZ2021) across Northern Ireland. These nest within 850 Super Data Zones (SDZ2021), which in turn nest within the 80 District Electoral Areas (DEA2014) and 11 Local Government Districts (LGD2014).</p>
		<p>More information is available in the <a href="https://www.nisra.gov.uk/publications/census-2021-output-geography-information-papers">Census 2021 output geography information papers</a></p>	

		<p>A summary of NISRA statistical geographies is also available in the <a href="https://www.nisra.gov.uk/files/nisra/publications/nisra-geography-fact-sheet.pdf" >NISRA Geography FactSheet</a></p>
		
		
		<h4>Postcodes</h4>
			<p>Postcodes are sourced from the <a href="https://www.nisra.gov.uk/support/geography/central-postcode-directory">Central Postcode Directory (CPD)</a>. </p>   
			<p>The CPD contains Northern Ireland postcodes and their average locations. It provides a lookup between postcodes and a range of administrative and statistical geographies, including Local Government Districts, District Electoral Areas, Data Zones, Super Data Zones and settlements. </p>
			<p>The version of the CPD used is July 2024.</p>
			
		<h4>Boundary Files</h4>
			<p>Boundary files used by the application are available from the following sources: </p>
			<ul>
				<li><a href="https://www.opendatani.gov.uk/@land-property-services-ordnance-survey-of-northern-ireland/osni-open-data-largescale-boundaries-local-government-districts-2012">Local Government Districts (2012)</a></li>
				<li><a href="https://www.nisra.gov.uk/support/geography/super-data-zones-census-2021">Super Data Zones</a></li>
				<li><a href="https://www.nisra.gov.uk/support/geography/data-zones-census-2021">Data Zones </a></li>
			</ul>

		<h4>Background Mapping</h4>
			<p>OpenStreetMap is used to provide the background mapping in the application.</p>


		<h3>Disclosure and rounding</h3>
		<p>Different disclosure and rounding rules apply to the datasets included in the Local Statistics Explorer.</p>
		<p>Use the &lsquo;i&rsquo; button beside a statistic to follow the link to its source data. Detailed metadata, definitions, methodology and notes are available from the NISRA Data Portal and Census webpages.</p>

		<h2>Timeliness</h2>
		<p>The Local Statistics Explorer is refreshed daily with updated data from the NISRA Data Portal.</p>
		<p>The &lsquo;i&rsquo; button beside each statistic shows the date on which that statistic was last updated.</p>

		<div class="div-grey-box new-datasets" aria-labelledby="new-datasets-heading">
			<h3 id="new-datasets-heading">Latest Updates</h3>

			{#if data.new_datasets.length > 0}
				<ul>
					{#each data.new_datasets as item (item.table_code || item.dataset_url)}
						<li>
							<a href={item.dataset_url} target="_blank" rel="noreferrer">
								{item.title}
							</a>

							<div>
								Last updated: {formatLastUpdated(item.last_updated)}

								{#if item.year}
									({item.year})
								{/if}
							</div>
						</li>
					{/each}
				</ul>
			{:else}
				<p>No new datasets have been added recently.</p>
			{/if}
		</div>

		<h2>Video guides</h2>
		<ul>
			<li>Northern Ireland Local Statistics Explorer</li>
			<li><a href="https://www.youtube.com/watch?v=HwGsqgdsiHM">Data Portal</a></li>
			<li><a href="https://www.youtube.com/watch?v=a6cn2yyITHU">Flexible Table Builder</a></li>
		</ul>

		<h2>Version history</h2>
		<p>The Northern Ireland Local Statistics Explorer was first released in October 2024.</p>
		<!-- <p>In XXXX 2024, further data was added on XXXX</p> -->
		
		<h2>About this application</h2>
		<p>The Local Statistics Explorer is based on and inspired by prototypes developed by the&nbsp;<a href="https://github.com/ONSvisual">ONS Digital Content team prototypes</a>. It has been adapted by NISRA to enable users to explore statistics for Northern Ireland and its local areas.</p>
		<p>The application is being developed as a prototype and will continue to be improved in response to user feedback.</p>

		<h2>Feedback and contact details</h2>
		<p>We welcome feedback on the Local Statistics Explorer and how it could be improved.</p>
		<p>You can provide feedback through our short <a href="https://dttselfserve.nidirect.gov.uk/NISRA/RateIt#/Northern_Ireland_Local_Statistics_Explorer">survey</a>.</p>
		<p>Contact details for each of the datasets are available in the &lsquo;i&rsquo; button.</p>
		<p>For general enquiries about the Local Statistics Explorer, email <a href="mailto:explore@nisra.gov.uk">explore@nisra.gov.uk</a>.</p>

	</div>

	<style>
		table {
		  width: 100%;
		  border-collapse: collapse;
		  margin: 20px 0;
		}
		th, td {
		  border: 1px solid #ddd;
		  padding: 8px;
		  text-align: left;
		}
		th {
		  background-color: #f2f2f2;
		}

		/* Styles for the New Datasets section */
  		.new-datasets {
    		margin-top: 30px;
  		}

  		.new-datasets h3 {
    		margin: 0 0 12px;
    		color: #3878c5;
    		font-size: 1.5em;
    		line-height: 1.2;
  		}

  		.new-datasets ul {
    		list-style: none;
    		margin: 0;
    		padding: 0;
  		}

  		.new-datasets li {
    		padding: 10px 0;
    		border-bottom: 1px solid #d9d9d9;
    		overflow-wrap: anywhere;
  		}

  		.new-datasets li:first-child {
    		padding-top: 0;
  		}

  		.new-datasets li:last-child {
    		padding-bottom: 0;
    		border-bottom: 0;
  		}

  		.new-datasets a {
    		color: #3878c5;
    		font-weight: bold;
  		}

  		.new-datasets li div,
  		.new-datasets > p {
    		margin: 4px 0 0;
  		}
	  </style>

</Section>