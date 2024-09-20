<script>
  import StackedBar from './StackedBar.svelte';
	import Legend from './Legend.svelte';
	export let data;
	export let height = 80;
	export let xKey = "x";
	export let yKey = "y";
	export let zKey = "ni";
  export let topic_prev_available = true;

  export let colors = ['#00205B', '#3878c5',   '#002417', '#BD00BD', 'lightgrey'];
  // export let colors = ['#00205B','#6C63AC', '#781C87',   '#C11B71', '#FB7979', '#801650', '#fbb15f', '#F66068',  'lightgrey'];
	//	export let colors = ['#212373','#781C87',  '#0D9AA2', '#C11B71', '#FB7979', '#F66068', '#746CB1', '#22D0B6', 'lightgrey'];
	// export let colors = ['#00205B','#6C63AC', '#781C87',   '#C11B71', '#FB7979', '#F66068', '#801650', '#0D9AA2', 'lightgrey'];
	export let decimals = null;
	export let label = null;
</script>

<div class="chart" style="padding-top: 3px; height: {zKey ? height * .72 : height}px;">
	<StackedBar {data} {yKey} {colors}/>
</div>
{#if (zKey && topic_prev_available) || (zKey == "ni") }
<div class="chart" style="height: {height * .28}px;">
	<StackedBar {data} yKey={zKey} {colors}/>
	{#if label}
	<div class="label">{label}</div>
	{/if}
</div>
{/if}
{#if zKey == "prev" && !topic_prev_available }
<div class="chart" style="height: {height * .28}px;">
	<StackedBar {data} yKey={zKey} {colors}/>
	<div class="label" style = "background-color: #d8d8d8 ;	color: #000000;">2011 comparison not available</div>
</div>
{/if} 

<div class="legend">
	<Legend {data} {xKey} {yKey} {zKey} {topic_prev_available} {decimals} {colors}/>
</div>


<style>
	.chart {
		width: 100%;
		position: relative;
	}
  .chart + .chart {
    border-top: 3px solid white;
  }
	.legend {
		width: 100%;
		margin-top: 3px;
	}
	.label {
		position: absolute;
		box-sizing: border-box;
		left: 0;
		top: 0;
		width: 100%;
		height: 100%;
		z-index: 1;
		padding: 0px 2px;
		font-size: 1em;
		color: white;
		opacity: 1;
		font-weight: bold;
		line-height: 1.2;
	}
	.label:hover {
		opacity: 1;
		background-color: rgba(0,0,0,0.3);
	}
</style>