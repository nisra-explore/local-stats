<script>
	import { setContext, onMount} from "svelte";
  import "../app.css";
	import { themes } from "$lib/config";
//	import Warning from "$lib/ui/Warning.svelte";
	import NISRAHeader from "$lib/layout/NISRAHeader.svelte";
	import NISRAFooter from "$lib/layout/NISRAFooter.svelte";
  import AnalyticsBanner from "$lib/layout/AnalyticsBanner.svelte";
  import Warning from "$lib/ui/Warning.svelte"

  // STYLE CONFIG
  // Set theme globally (options are 'light' or 'dark')
  let theme = "light";
  setContext("theme", themes[theme]);

  // GOOGLE ANALYTICS
  // Settings for page analytics. Values must be shared with <AnalyticsBanner> component
  const analyticsId = "GTM-WKK8ZWP";
  const analyticsProps = {
    "contentTitle": "Northern Ireland Local Statistics Explorer",
    "releaseDate": "20220823",
    "contentType": "exploratory"
  };

  let c;
  let f;
  let space_needed;
	
	const debounce = (func, delay) => {
		let timer;

		return function () {
			const context = this;
			const args = arguments;
			clearTimeout(timer);
			timer = setTimeout(() => func.apply(context, args), delay);
		};
	};
	
	const setSpaceHeight = () => {

    let calculated_space = window.innerHeight - c.clientHeight - f.clientHeight;

    if (calculated_space < 0) {
      space_needed = `0px`;
    } else {
		  space_needed = `${calculated_space}px`;
    }

	};
	
	const debouncedSetSpaceHeight = debounce(setSpaceHeight, 100);

  onMount(() => {

    let calculated_space = window.innerHeight - c.clientHeight - f.clientHeight;

    if (calculated_space < 0) {
      space_needed = `0px`;
    } else {
		  space_needed = `${calculated_space}px`;
    }

    window.addEventListener('resize', debouncedSetSpaceHeight);
    window.addEventListener('click', debouncedSetSpaceHeight);
    window.addEventListener('load', debouncedSetSpaceHeight);
    window.addEventListener('mousemove', debouncedSetSpaceHeight);
   
  });
  

</script>

<svelte:head>
<link rel="icon" href="https://www.nisra.gov.uk/sites/nisra.gov.uk/themes/nisra_theme/favicon.ico" /> 
<link rel="apple-touch-icon" href="https://www.nisra.gov.uk/sites/nisra.gov.uk/themes/nisra_theme/favicon.ico">
</svelte:head>

<div bind:this={c}>

  <AnalyticsBanner {analyticsId} {analyticsProps}/>

  <Warning/>

    <NISRAHeader/>

  <slot/>
</div>

<div bind:this={f} style = "margin-top: {space_needed}">
  <NISRAFooter/>
</div>