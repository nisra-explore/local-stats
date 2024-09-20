<script context="module">
</script>
<script>
  import { base } from "$app/paths";
  import { assets } from "$app/paths";
  import { app_inputs } from "$lib/config";
  import Section from "$lib/layout/Section.svelte";
  import Select from "$lib/ui/Select.svelte";
  import { goto } from "$app/navigation";

  export let data;

  function menuSelect(ev) {
      goto(`${base}/${ev.detail.value}/`, { noscroll: true });
    }

</script>

<svelte:head>
  <title>Northern Ireland Local Statistics Explorer</title>
  <meta name="description" content="">
  <meta property="og:title" content="Northern Ireland Local Statistics Explorer" />
	<meta property="og:type" content="website" />
	<meta property="og:url" content="{app_inputs.base}/" />
	<meta property="og:description" content="Explore NISRA data for places in Northern Ireland." />
	<meta name="description" content="Explore NISRA data for places in Northern Ireland." />
</svelte:head>

<Section column="wide">
  <div class="block">


  <!-- <div>This application contains key statistics for Northern Ireland, the 11 Local Government Districts and the areas within.  
  It will be updated with new data, more topics and lower geographies as they become available.  
  </div>
  -->


    <div class="grid">

      <div class = "div-grey-box" style = "overflow: visible;">

        <span style="font-size: 1.5em; font-weight: bold;color: #3878c5; line-height: 1em;">Explore key statistics for any area in Northern Ireland</span>


       
        <Select
        search_data = {data.search_data}
        group="typestr"
        search={true}
        on:select={menuSelect}
        />

       <p style="font-size: 1.5em;color: #3878c5;font-weight: bold; margin-top: 20px"> Or select your council area</p>
        <a href="{base}/N09000001">Antrim and Newtownabbey</a>,
          <a href="{base}/N09000011">Ards and North Down</a>,
          <a href="{base}/N09000002">Armagh City, Banbridge and Craigavon</a>,
          <a href="{base}/N09000003">Belfast</a>,
          <a href="{base}/N09000004">Causeway Coast and Glens</a>,
          <a href="{base}/N09000005">Derry City and Strabane</a>,
          <a href="{base}/N09000006">Fermanagh and Omagh</a>,
          <a href="{base}/N09000007">Lisburn and Castlereagh</a>,
          <a href="{base}/N09000008">Mid and East Antrim</a>,
          <a href="{base}/N09000009">Mid Ulster</a>,
          <a href="{base}/N09000010">Newry, Mourne and Down</a>
       
      </div> 

      

      <div class = "div-grey-box">
        <span style="font-size: 1.5em; font-weight: bold; color: #3878c5; line-height: 1em;">Click on the map to view Northern Ireland as a whole</span>

        <a href="{base}/N92000002/">
          <picture id ="ni-map">
            <img style="width:400px;" src="{assets}/img/Northern_Ireland_Map.svg" alt="Outline of Northern Ireland">
          </picture>
        </a>
      </div>

    </div>

  </div>
</Section>

<style>
	.block {
    margin-top: 55px;
    display: block;
	}
	.title {
		display: inline-block;
		margin-top: -3px;
	}


  .column {
  		float: left;
  		padding-left: 40px;
  		padding-right: 40px;
		padding-top: 10px;
  		padding-bottom: 10px;
  		
	}
	.left {
		max-width: 40%;
		padding-top: 0px;
  		padding-bottom: 10px;
	}
	.right {
		max-width: 60%;
		padding-top: 0px;
  		padding-bottom: 10px;	}
	.row:after {
		content: "";
		display: table;
		clear: both;
		
	}

  .grid {
		display: grid;
		width: 100%;
		grid-gap: 30px;
		grid-template-columns: repeat(auto-fit, minmax(min(280px, 100%), 1fr));
		justify-content: stretch;
		page-break-inside: avoid;
	}

  #ni-map {
    filter: drop-shadow(3px 5px 2px rgb(0 0 0 / 0.4));
  }

  #ni-map:hover {
    filter: brightness(0.75) drop-shadow(5px 7px 4px rgb(0 0 0 / 0.5));
  }

</style>