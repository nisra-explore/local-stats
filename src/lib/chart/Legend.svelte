<script>
	import { changeClass, changeStrLegend } from "../utils";

	export let data;
	export let xKey = "x";
	export let yKey = "y";
	export let zKey = "ni";
	export let topic_prev_available = true;
	export let colors = ['#3878c5','#00205B', '#308182',   '#002417', '#BD00BD', 'lightgrey'];
	// export let colors = ['#00205B','#6C63AC', '#781C87',   '#C11B71', '#FB7979', '#801650', '#fbb15f', '#F66068',  'lightgrey'];
//	export let colors = ['#00205B','#6C63AC', '#781C87',   '#C11B71', '#FB7979', '#F66068', '#801650', '#0D9AA2', 'lightgrey'];
//	export let textColor = '#555';
//	export let mutedColor = '#999';
	export let decimals = null;
//	export let round = false;

	
	$: sum = data.map(d => d[yKey]).reduce((a, b) => a + b, 0);
	$: psum = data.map(d => d[zKey]).reduce((a, b) => a + b, 0);

	function toPerc(val) {
		let str;
		if (decimals) {
			str = ((val / sum) * 100).toFixed(decimals) + '%';
//		} else if ((val / sum) * 100 < 0.1) {
//			str = '<0.1%';
		} else if ((val / sum) * 100 < 1) {
			str = '<1%';
		} else {
			str = ((val / sum) * 100).toFixed(0) + '%';
		}
		return str;
	}
</script>




<table class="legend">
	<tbody>
		{#each data as item, i}
		<tr>
			<td>
				<svg width="20" height="30" class="bullet">
					<rect  width="20" height="30" style="fill:{colors[i]};"></rect>
				</svg> {item[xKey]} 
			</td>
			<td class="cell-right" style="vertical-align:top">
				{toPerc(item[yKey])}
				{#if zKey == "prev" && topic_prev_available}
					<span class="" style="color: #1460aa">(2011 {changeStrLegend(Math.round(item[zKey]), '%)')}</span>
				{:else if  zKey == "prev" && !topic_prev_available}
					<span class="" style="color: #1460aa"></span>
				{:else if zKey}
					<span class="" style="color: #1460aa">(NI {toPerc(item[zKey])})</span>
				{/if}
			
			</td>
		</tr>
		{/each}
	</tbody>
</table>

<style>
/* 	ul {
		margin: 0;
		padding: 0;
		font-size: 0.85em;
		text-transform: none;
	}
	li {
		display: inline-block;
		margin-right: 10px;
	} */
	.bullet {
  	height: 15px;
  	width: 15px;
		display: inline-block;
		transform: translate(0, 2px);
	}
/* 	.round {
		border-radius: 50%;
		transform: scale(0.9);
		transform: translate(0, 3px);
	}
	.increase {
		color: darkgreen;
	}
	.increase::before {
		content: '▲';
		color: darkgreen;
	}
	.decrease {
		color: darkred;
	}
	.decrease::before {
		content: '▼';
		color: darkred;
	}
	.nochange {
		color: grey;
		text-transform: none;
	} */
	table.legend {
		width: 100%;
		border-spacing: 0;
		border-collapse: collapse;
		margin-top: 1px;
	}
	td {
		font-size: 0.85em;
		margin: 0;
	}
	td.cell-right {
		font-size: 0.85em;
		text-align: right;
		width: 100px;
	}
/* 	.legend-vis {
		display: inline-block;
		width: 0.85rem;
		height: 0.85rem;
		transform: translate(0,3px);
	} */
</style>