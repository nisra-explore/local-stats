<script>
	export let data;
	export let xKey = "perc";
	export let yKey = "category";
	export let zKey = "group";
	export let formatTick = d => Math.round(100 * d);
	export let suffix = "%";
	export let barHeight = 25;
	export let markerWidth = 3;
	
	function groupData(data, key) {
		let data_indexed = {};
		for (const d of data) {
			if (!data_indexed[d[key]]) {
				data_indexed[d[key]] = {
					label: d[key],
					values: []
				};
			}
			data_indexed[d[key]].values.push(d);
		}
		
		let data_grouped = [];
		for (const key in data_indexed) {
			data_grouped.push(data_indexed[key]);
		}
		
		return data_grouped;
	}
	
	$: xDomain = [0, Math.max(...data.map(d => d[xKey]))];
	$: yDomain = data.map(d => d[yKey]).filter((v, i, a) => a.indexOf(v) === i);
	$: zDomain = data.map(d => d[zKey]).filter((v, i, a) => a.indexOf(v) === i);
	
	$: xScale = (value) => (value / xDomain[1]) * 100;
	
	$: data_grouped = groupData(data, yKey);
</script>

{#if zDomain[1]}
<ul class="legend">
	{#each zDomain as group, i}
	<li>
		<div class="legend-vis {i == 0 ? 'bar' : 'marker'}" style:height="1rem" style:width="{i == 0 ? '1rem' : markerWidth + 'px'}"></div>
		<span class="{i == 0 ? 'bold' : 'brackets'}">{group}</span>
	</li>
	{/each}
</ul>
{/if}

{#each data_grouped as group}
	<div class="label-group">
		{group.label}
		{#each group.values as d, i}
		<span class="{i == 0 ? 'bold' : 'sml brackets'}" style="color: {i == 0 ? '#000000' : '#1460aa'}">{formatTick(d.perc/100)}{suffix}</span>
		{/each}
	</div>
	<div class="bar-group" style:height="{barHeight}px">
	{#each group.values as d, i}
		{#if i == 0}
		<div class="bar" style:left="0" style:width="{xScale(d[xKey])}%"/>
		{:else}
		<div class="marker" style:left="calc({xScale(d[xKey])}% - {markerWidth / 2}px)" style:border-left-width="{markerWidth}px"/>
		{/if}
	{/each}
	</div>
{/each}

<style>
	.bold {
		font-weight: normal;
	}
	.sml {
		margin-left: 3px;
		font-size: .85rem;
	}
	.brackets::before {
		content: "(";
	}
	.brackets::after {
		content: ")";
	}
	.label-group {
		margin: 2px 0 0 0;
		font-size: 0.85rem;
	}
	.bar-group {
		display: block;
		position: relative;
		width: 100%;
		font-size: 0.85rem;

	}
	.bar-group > div {
		position: absolute;
		height: 100%;
		top: 0;
	}
	.bar {
		background-color: #00205b;
	}
	.marker {
		border-left-color: #308182;
		border-left-style: solid;
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