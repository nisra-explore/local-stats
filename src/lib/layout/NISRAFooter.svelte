<script>
 // import { assets } from "$app/paths";
	import { getContext } from 'svelte';
	import Section from "$lib/layout/Section.svelte";


//	export let theme = getContext('theme');
</script>

<!-- svelte-ignore missing-declaration -->
<Section column="wide">
<div class="block" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(280px, 100%), 1fr)); justify-content: stretch;">
<!-- <div style="margin-left:16px; padding-right:16px;">
	<h3 style="margin-bottom:10px; line-height: 1.78;">Download</h3>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		 <a href="https://www.nisra.gov.uk/publications/census-area-explorer-2021-and-2011-data" class="link"><strong>Download</strong> Census 2011 and 2021 data from this app</a>
	</li>
  </div>
  
  <div style="margin-left:16px; padding-right:16px;">
	<h3 style="margin-bottom:10px; line-height: 1.78;">Contact and further resources</h3>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/contacts/census-customer-services">Contact Census</a>
  	</li>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/statistics/census/2021-census">Census 2021</a>
  	</li>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/statistics/2021-census/results">Census 2021 results</a>
  	</li>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins">Statistical Bulletins</a>
  	</li>
	  <li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/publications/census-2021-infographics">Infographics</a>
  	</li>
	
  </div>

  <div style="margin-left:16px;">
	<h3 style="margin-bottom:10px; line-height: 1.78;">About this app</h3>
	This web application is based on and inspired by the <a href="https://github.com/ONSvisual">ONS Digital Content team prototypes</a>. 
	It has been modified by NISRA and released as a prototype to explore Census data for Northern Ireland. We welcome feedback from users through our short <a href="https://consultations2.nidirect.gov.uk/dof/area-explorer-feedback/">survey</a>.
		
  </div>

  </div> -->
</Section>
  
<footer style="color: #ffffff; background-color: #00205b;">
	<div class="col-wide" data-analytics="footer">
		<div class="row">
			<div class="column left">
				<h3 style="padding-top: 0px">Links</h3><br>
				<ul>
					<li><a href="https://data.nisra.gov.uk/" class="link" style="color: #ffffff">NISRA Data Portal</a></li>
					<li><a href="https://build.nisra.gov.uk/" class="link" style="color: #ffffff">Census Flexible Table Builder</a></li>
					<li><a href="https://www.opendatani.gov.uk/" class="link" style="color: #ffffff">OpenDataNI</a></li>
					<li><a href="https://www.nidirect.gov.uk" class="link" style="color: #ffffff">NIDirect</a></li>
					<li><a href="https://www.gov.uk/" class="link" style="color: #ffffff">GOV.UK</a></li>
				</ul>
			</div>	
			<div class="column right">
				<h3>Follow NISRA</h3><br>
				<ul> 
					<li><a href="https://www.facebook.com/nisra.gov.uk" class="link" style="color: #ffffff">Facebook</a></li>
					<li><a href="https://twitter.com/NISRA" class="link" style="color: #ffffff">X (Twitter)</a></li>
					<li><a href="https://www.youtube.com/user/nisrastats" class="link" style="color: #ffffff">YouTube</a></li>
				</ul>
			</div>
		</div>

		<div class="flex-list">
			<ul>
				<li><a href="https://www.nisra.gov.uk/crown-copyright" class="link" style="color: #ffffff">&copy Crown Copyright</a></li>
				<li><a href="https://www.nisra.gov.uk/contact" class="link" style="color: #ffffff">Contact us</a></li>
				<li><a href="https://www.nisra.gov.uk/terms-and-conditions" class="link" style="color: #ffffff">Terms and conditions</a></li>
				<li><a href="https://www.nisra.gov.uk/cookies" class="link" style="color: #ffffff">Cookies</a></li>
				<li><a href="https://www.nisra.gov.uk/nisra-privacy-notice" class="link" style="color: #ffffff">Privacy</a></li>
				<li><a href="https://www.nisra.gov.uk/accessibility-statement-nisra" class="link" style="color: #ffffff">Accessibility Statement</a></li>
			</ul>
		</div>
	</div>
</footer>

<style>
	footer {
		padding-bottom: 32px;
		font-size: 18px;
	}
	footer a.link {
		-webkit-box-sizing: border-box;
		box-sizing: border-box;
		text-decoration: none;
		display: inline-block;
	}
	footer a.link:hover {
		text-decoration: underline;
	}
	footer a.link:active {
		outline: 3px solid transparent;
		background-color: #fd0;
		-webkit-box-shadow: 0 -2px #fd0, 0 4px #222;
		box-shadow: 0 -2px #fd0, 0 4px #222;
		color: #222;
		text-decoration: none;
	}
 	ul {
		padding: 0;
		margin: 0;
	}
	li {
		margin-right: 18px;
		list-style-type: none;
	}
/* 	.logo-img {
		margin-bottom: 2px;
		width: 120px;
	} */
/* 	.ogl-img {
		margin: 0 0.5rem 0.2rem 0;
		width: 59px;
		height: 24px;
		vertical-align: middle;
	} */
/* 	.license {
		vertical-align: top;
	} */
/* 	a img:hover {
		cursor: pointer;
	} */
		.column {
  		float: left;
  		padding-left: 40px;
  		padding-right: 40px;
		padding-top: 10px;
  		padding-bottom: 10px;
  		
	}
	.left {
		max-width: 30%;
		padding-top: 0px;
  		padding-bottom: 10px;
	}
	.right {
		max-width: 70%;
		padding-top: 0px;
  		padding-bottom: 10px;	}
	.row:after {
		content: "";
		display: table;
		clear: both;
		
	}
	.flex-list {
		position: relative;
		margin: 0em;
		overflow: hidden;
		padding-top: 10px;
  		padding-bottom: 0px;


	}
	.flex-list ul {
		display: flex;
		flex-direction: row;
		flex-wrap: wrap;
		justify-content: space-between;
		margin-left: -1px;
	}
	.flex-list li {
		flex-grow: 1;
		flex-basis: auto;
		margin: .25em 0;
		padding: 0 1em;
		text-align: center;
		border-left: 1px solid #ccc;
		background-color: #00205b;
		font-size: 14px;
	}
</style>