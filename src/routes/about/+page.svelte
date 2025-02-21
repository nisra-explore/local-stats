<script>
	import Section from "$lib/layout/Section.svelte";
	import { base } from "$app/paths";

  </script>




<Section column="wide">
	<a  href='{base}/'>Home</a>

	<div class="row">


		<h1>About the Northern Ireland Local Statistics Explorer</h1>


		<h2>What is the app?</h2>
		<p>Welcome to NISRA's Northern Ireland Local Statistics Explorer: a high level overview of Northern Ireland's statistical information</p>

		<p>Explore the collection of statistical information published by the Northern Ireland Statistics and Research Agency (NISRA) with our 
			interactive web page, the NISRA Local Statistics Explorer. It is designed to provide users with easy access to key statistics for Northern Ireland and its local areas. </p>

		<h2>Features:</h2>
		<ul> 
			<li>Comprehensive Data Coverage: a selection of statistical data covering various aspects of life in Northern Ireland, including demographics, economy, education, health, and more.</li>
			<li>User-Friendly Interface: Navigate through the intuitive interface, designed to make exploring statistical information a seamless experience for users of all levels.</li>
			<li>Data Downloads and Sharing: Get links to download datasets for further analysis.</li>
		</ul>
		
		<h2>Sources of data</h2>
		
		<p>All of the data is sourced from the  <a href="https://data.nisra.gov.uk">NISRA Data Portal</a> and the <a href="https://explore.nisra.gov.uk/area-explorer-2021/">Census Area Explorer</a>.</p>
		<p>At each statistic the &lsquo;i&rsquo; button provides definitions, source, contact details and date last updated.&nbsp; 
			A more statistics section under each topic provides details of other statistics that are available.</p>
		
		<h3>The NISRA Data Portal</h3>
		<p>The <a href="https://data.nisra.gov.uk">NISRA Data Portal</a> is a repository for data on our population, society and economy.  </p>
		<p>The Data Portal is continually refreshed with new and updated datasets from across the NICS and Public Sector.  
			It gives users the opportunity to view and filter data sets, plot interactive charts and visualise data on interactive maps, save queries, create favourite datasets and widgets, access data in multiple formats - xlsx, csv, JSON-stat, px and share results and automate processes using API queries.</p>
		
		<p><a href = "https://www.nisra.gov.uk/nisra-data-portal-faqs-and-training-materials">Training Materials</a> (NISRA Data Portal user guide, instructional video and FAQ section) have been published to help you navigate and use the new system.  </p>
		<p>You can sign-up to attend online training sessions by emailing <a href="mailto:info@nisra.gov.uk">info@nisra.gov.uk</a> to register your interest.  Further help, if needed, will also be available on request.</p>


		<h3>The Census Area Explorer</h3>
		<p>The census happens only once every 10 years. It gives us the most accurate estimate of all the people and households in Northern Ireland.  The last census in Northern Ireland took place on 21 March 2021.</p>
		<p>You can explore the results of Census 2021 for Northern Ireland through the Census Area Explorer, the NISRA website or the Flexible Table Builder.</p>	
		
		<p>The <a href="https://explore.nisra.gov.uk/area-explorer-2021/">Census Area Explorer</a> is an easy to use interactive tool that the user can choose an area and compare the Census 2021 results with Northern Ireland or the Census 2011.</p>
		<p>The <a href="https://www.nisra.gov.uk/statistics/census">NISRA website</a> has news, results, outputs prospectus and information on previous censuses.</p>
		<p>	The <a href="https://build.nisra.gov.uk/en/">Flexible Table Builder</a> enables you to build your own table or search through and customise ready-made tables.</p>

		<h3>Disclosure</h3>
		<p>Different disclosure rules apply for each of the datasets.  Please refer to the link to the data in the &lsquo;i&rsquo; button.  Detailed metadata and notes are available on the Data Portal and the Census webpages.</p>

		<h3>Rounding</h3>
		<p>Different rounding rules apply for each of the datasets.  Please refer to the link to the data in the &lsquo;i&rsquo; button.  Detailed metadata and notes are available on the Data Portal and the Census webpages.</p>


		<h3>Geographical Levels</h3>

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
				<td>District Electoral Area (DEA2021), called electoral areas in this web application</td>
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
		<p>Northern Ireland is divided into 11 Local Government Districts (LGD) which are also known as councils.  
			 Further information is available in an <a href='https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/11DC_Guidance_1_0.pdf'>LGD 2014 information paper</a> produced by NISRA.
			 The 11 new Districts became operational in April 2015. Each LGD is subdivided into district electoral areas.</p>
		 <p>District Electoral Areas (DEA’s) are the units made up of groups of local government wards, usually of around 5-7, which are used for the purpose of administration of local government elections and are also used to help District Councils develop strategy for service delivery.
			 </p> 

		<h4>Statistical geographies</h4>
		<p>Data Zones and Super Data Zones are statistical output geographies created to support the release of local-level Census 2021 statistics.</p>
		<p>There are 850 Super Data Zones (SDZ2021) across Northern Ireland and the 3,780 Data Zones (DZ2021) nest within this geography. These two geographies nest within the 80 District Electoral Areas (DEA2014) and 11 Local Government Districts (LGD2014).</p>
		<p>There is more information in <a href="https://www.nisra.gov.uk/publications/census-2021-output-geography-information-papers">Census 2021 output geography information papers</a></p>	

		<p>A summary of other NISRA Statistical Geographies is available in the <a href="https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/nisra-geography-fact-sheet.pdf" >NISRA Geography FactSheet</a></p>
		
		
		<h4>Postcodes</h4>
			<p>Postcodes are sourced from the <a href="https://www.nisra.gov.uk/support/geography/central-postcode-directory">Central Postcode Directory (CPD)</a>.  The CPD is a list of postcodes in Northern Ireland, with the average location of the addresses in each postcode. It is used to provide a direct lookup between postcodes and a range of administrative and statistical geographies including Local Government Districts, District Electioral Areas, Data Zones, Super Data Zones and Settlements.   
				The version of the CPD used is July 2024.</p>
			
		<h4>Boundary Files</h4>
			<p>The boundary files used in the application are available to download at :</p>
			<ul>
				<li><a href="https://www.opendatani.gov.uk/@land-property/osni-open-data-largescale-boundaries-local-government-districts-1993">Local Government Districts (1993)</a></li>
				<li><a href="https://www.nisra.gov.uk/support/geography/super-data-zones-census-2021">Super Data Zones</a></li>
				<li><a href="https://www.nisra.gov.uk/support/geography/data-zones-census-2021">Data Zones </a></li>
			</ul>

		<h4>Background Mapping</h4>
			<p>OpenStreet Map has been used to provide background mapping</p>



		<h2>Video guides</h2>
		<ul>
			<li>Northern Ireland Local Statistics Explorer</li>
			<li><a href="https://www.youtube.com/watch?v=HwGsqgdsiHM">Data Portal</a></li>
			<li><a href="https://www.youtube.com/watch?v=a6cn2yyITHU">Flexible Table Builder</a></li>
		</ul>
	
	
	
		<h2>Timeliness</h2>
		<p>This web application is refreshed daily with updated data from the NISRA data portal.</p>

		<h2>Versions</h2>
		<p>This app was originally released in October 2024.</p>
		<!-- <p>In XXXX 2024, further data was added on XXXX</p> -->
		
		<h2>About this app</h2>
		<p>This web application is based on and inspired by the&nbsp;<a href="https://github.com/ONSvisual">ONS Digital Content team prototypes</a>. It has been modified by NISRA and released as a prototype to explore statistical data for Northern Ireland.</p>

		<h2>Feedback and contact details</h2>
		<p>This is a prototype application and we are very keen to get feedback on how it can be improved.</p>
		<p>We welcome feedback from users through our short <a href="https://dttselfserve.nidirect.gov.uk/NISRA/RateIt#/Northern_Ireland_Local_Statistics_Explorer">survey</a>.</p>
		<p>Contact details for each of the datasets are available in the &lsquo;i&rsquo; button.</p>
		<p>Contact <a href="mailto:explore@nisra.gov.uk">explore@nisra.gov.uk</a> for further information.</p>

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
	  </style>

	  
</Section>