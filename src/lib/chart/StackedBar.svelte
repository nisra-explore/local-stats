<script>
	export let data;
	//export let xKey = "x";
	export let yKey = "y";
	export let colors = ['#308182', '#3878c5',   '#002417', '#BD00BD', 'lightgrey'];
//	export let colors = ['#00205B','#6C63AC', '#781C87',   '#C11B71', '#FB7979', '#F66068', '#801650', '#0D9AA2', 'lightgrey'];
//	export let colors = ['#212373','#781C87',  '#0D9AA2', '#C11B71', '#FB7979', '#F66068', '#746CB1', '#22D0B6', 'lightgrey'];

  let sum, breaks;
	
	function update() {
		// Calculate sum and breaks from 0% to 100%, and round breaks to nearest 1
	  sum = data.map(d => d[yKey]).reduce((a, b) => a + b, 0);
	  let brks = [0];
	  data.forEach(d => brks.push(brks[brks.length - 1] + d[yKey]));
    breaks = brks;
	}
	
	$: (data || yKey) && update();
</script>

{#if sum && breaks}
<svg class="stack">
	{#each data as row, i}
	<rect class="cell" x={(breaks[i] / sum) * 100}% style="width: {(row[yKey] / sum) * 100}%; fill: {colors[i]}"/>
	{/each}
</svg>
{/if}

<style>
 	.stack {
    position: relative;
		width: 100%;
		height: 100%;
	}
	.cell {
		position: absolute;
    height: 100%;
    top: 0;
	} 
</style>