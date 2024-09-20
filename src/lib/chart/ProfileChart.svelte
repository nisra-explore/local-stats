<script>
	export let data;
	export let xKey = "category";
	export let yKey = "perc";
	export let zKey = "group";
	export let height = 100;
	export let markerWidth = 3;
	
	function stackData(data, key) {
		let data_indexed = {};
		
		for (const d of data) {
			if (!data_indexed[d[key]]) {
				data_indexed[d[key]] = {
					label: d[key],
					values: []
				};
			}
			let len = data_indexed[d[key]].values.length;
			let offset = len == 0 ? 0 : d[yKey] - data_indexed[d[key]].values[len - 1][yKey];
			data_indexed[d[key]].values.push({...d, offset});
		}
		
		let data_stacked = [];
		for (const key in data_indexed) {
			data_stacked.push(data_indexed[key]);
		}
		console.log(data_stacked);
		return data_stacked;
	}
	
	$: xDomain = data.map(d => d[xKey]).filter((v, i, a) => a.indexOf(v) === i);
	$: yDomain = [0, Math.max(...data.map(d => d[yKey]))];
	$: zDomain = data.map(d => d[zKey]).filter((v, i, a) => a.indexOf(v) === i);
	
	$: yScale = (value) => Math.abs(value / yDomain[1]) * 100;
	
	$: data_stacked = stackData(data, zKey);
</script>

{#if zDomain[1]}
<ul class="legend">
	{#each zDomain as group, i}
	<li>
		<div class="legend-vis {i == 0 ? 'bar' : 'markerSmall'}" style:height="1rem" style:width="{i == 0 ? '1rem' : markerWidth + 'px'}"></div>
		<span class="{i == 0 ? 'bold' : 'brackets'}">{group}</span>
	</li>
	{/each}
</ul>
{/if}

<div class="bar-group" style:height="{height}px">
	{#each data_stacked as stack, i}
	{#if i == 0}
	{#each stack.values as d, j}
	<div class="bar" style:top="{100 - yScale(d[yKey])}%" style:height="{yScale(d[yKey])}%" style:left="{(j / xDomain.length) * 100}%" style:width="calc({(1 / xDomain.length) * 100}% - 2px)"/>
	{/each}
	
	{:else}
	{#each stack.values as d, j}
	<div class="marker" style:top="calc(100% - {d.offset < 0 ? yScale(d[yKey] - d.offset) : yScale(d[yKey])}%)" style:height="{yScale(d.offset)}%" style:left="{(j / xDomain.length) * 100}%" style:width="{(1 / xDomain.length) * 100}%" style="border-{d.offset < 0 ? 'top' : 'bottom'}: none"/>
	{/each}
	{/if}
	{/each}
</div>

<div class="x-scale">
	<div class="row" style:width="100%">
		<div class="column">0-14</div>
		<div class="column">15-39</div>
		<div class="column">40-64</div>
		<div class="column">65+</div>
	  </div></div>

<style>
	.column {
	float: left;
	width: 25%;
	text-align: center;
	}
	.bold {
		font-weight: normal;
	}
	.brackets::before {
		content: "(";
	}
	.brackets::after {
		content: ")";
	}
	.bar-group, .x-scale {
		display: block;
		position: relative;
		width: 100%;
		font-size: 0.85rem;

	}
	.bar-group > div {
		position: absolute;
		height: 100%;
		top: 0;
		font-size: 0.85rem;

	}
	.x-scale > div {
		position: absolute;
		top: 0;
	}
	.bar {
		background-color: #00205b;
		border-left: 2px solid rgb(245, 245, 246);
		border-right: 2px solid rgb(245, 245, 246);
	}
	.markerSmall {
		border-left: 4px solid #308182;
	}
	.marker {
		border-left: 4px solid #308182;
		border-bottom: 4px solid #308182;
		border-top: 4px solid #308182;
	}
	ul.legend {
		list-style-type: none;
		padding: 0;
		margin: 0 0 5px 0;
		font-size: 0.85rem;

	}
	ul.legend > li {
		display: inline-block;
		margin: 0 10px 0 0;
	}
	.legend-vis {
		display: inline-block;
		transform: translate(0,3px);
	}
</style>