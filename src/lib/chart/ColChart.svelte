<script>
	import { LayerCake, Svg, Html } from 'layercake';
	import { scaleBand } from 'd3-scale';

	import Col from './Col.svelte';
	import AxisX from './AxisX.svelte';
	
	export let data;
	export let suffix = '%';
	export let decimals = null;
	export let fill = '#00205B';
	
	export let xKey = "x";
	export let yKey = 'y';
	export let zKey= null;
	
	// export let colors = ['#00205B','#00205B', '#00205B',   '#00205B'];

	$: xDomain = data.map(d => d[xKey]);
	$: yDomain = [0, Math.max(...data.map(d => d[yKey]))];
	$: formatVal = d => d.toFixed(decimals) + suffix;



</script>

<style>
	.chart-container {
		width: 100%;
		height: 100%;
	}

	
</style>

<div class="chart-container">
	<LayerCake
		padding={{ top: 15, right: 0, bottom: 20, left: 0 }}
		x={xKey}
		y={yKey}
		z={zKey}
		xScale={scaleBand().paddingInner([0.02]).round(true)}
		{xDomain}
		{yDomain}
		zDomain={yDomain}
		data={data}
	>
		<Svg>
			<Col {fill} {formatVal}/>
			<AxisX
				gridlines={false}
			/>
		</Svg>

	</LayerCake>
</div>


