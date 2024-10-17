<script>
	import { createEventDispatcher } from 'svelte';
	
	const dispatch = createEventDispatcher();
	
	export let search_data;
	export let selected = null;
	export let placeholder = "Enter a town, postcode or area name";
	export let value = "code";
	export let label = "name";
	export let group = null;
	export let search = false;
	
	let selectedPrev = selected;
	let selectedItem = selected ? search_data.find(d => { d[value] == selected[value] }) : null;
	let expanded = false;
	let filter = '';
	let active = null;
	let filtered;
	let el;
	let input;
	let items = [];
	
	function sleep(ms) {
		return new Promise(resolve => setTimeout(resolve, ms));
	}

	function postcode_space(x) {
		
		if (x.length > 5 && x.substr(0, 2).toUpperCase() == "BT" && x.indexOf(" ") == -1) {
			x = x.slice(0, -3) + " " + x.substr(-3);
		}
		return x
	}
	
	$: regex = filter ? new RegExp(postcode_space(filter), 'i') : null;
	$: {
		filtered = regex ? search_data.filter(option => regex.test(option[label])) : search_data;
		active = 0;
	}
	
	function toggle(ev) {
		ev.stopPropagation();
		filter = '';
		expanded = !expanded;
		sleep(10).then(() => {
			if (input && expanded) {
				input.focus();
			}
		});
	}

	function typing(ev) {
		expanded = true;
	}
	
	function select(option) {
		selected = option;
		expanded = false;
		localStorage.setItem("search_code", option.code);
		localStorage.setItem("search_name", option.name);
		input.value = "";
		dispatch('select', {
			selected: option,
			value: option[value]
		});
	}
	
	function unSelect(ev) {
		ev.stopPropagation();
		selected = null;
		selectedPrev = null;
		selectedItem = null;
		dispatch('select', {
			selected: null,
			value: null
		});
	}
	
	function doKeydown(ev) {
		if (expanded && filtered[0] && Number.isInteger(active)) {
			if (ev.keyCode === 38) {
				active -= active > 0 ? 1 : 0;
				items[active].scrollIntoView({ block: 'nearest', inline: 'start' });
			} else if (ev.keyCode === 40) {
				active += active < filtered.length - 1 ? 1 : 0;
				items[active].scrollIntoView({ block: 'nearest', inline: 'end' });
			}
		}
	}
	
	function doKeyup(ev) {
		if (filtered[0] && Number.isInteger(active)) {
			if (ev.keyCode === 13) {
				select(filtered[active]);
			}
		}
	}
	
	function onClick(ev) {
		if(ev.target !== el){
			expanded = false;
			active = 0;
		}
	};
	
	$: if (selectedPrev != selected) {
		selectedItem = search_data.find(d => d[value] == selected[value]);
		selectedPrev = selected;
	}
</script>

<svelte:window on:click={onClick}/>

<div id="select" class:active={expanded} on:keydown={doKeydown}	>
	{#if selectedItem && !search}
	<a id="toggle" class="selected" on:click={toggle}>
		<span class="selection">{selectedItem[label]} {#if group}<small>{selectedItem[group]}</small>{/if}</span>
	</a>
	{:else}
	<a id="toggle" on:click={toggle} on:focus={toggle} >
		<input on:keydown={typing} type="text" placeholder={placeholder} bind:value={filter} autocomplete="false" bind:this={input} on:keyup={doKeyup} autofocus="autofocus" onfocus="this.select()" />

	</a>
	{/if}
	
	{#if expanded}
	<div id="dropdown" bind:this={el} style="top: 0; margin-top: 50px;">
		<ul>
			{#if filter.length < 3}
			<li>Type a name...</li>
			{:else if filtered[0] && group}
			{#each filtered as option, i}
			<li class:highlight="{active == i}" on:click="{() => select(option)}" on:mouseover="{() => active = i}" bind:this="{items[i]}">
				{#if option[group].slice(0, 4) == "View"}
					<small>{option[label]}</small> <span class = "view">{option[group]}</span>
				{:else}
					<span class = "view">View: {option[label]} {option[group]}</span>
				{/if}
			</li>
			{/each}
			{:else if filtered[0]}
			{#each filtered as option, i}
			<li class:highlight="{active == i}" on:click="{() => select(option)}" on:mouseover="{() => active = i}" bind:this="{items[i]}">
				{option[label]}
			</li>
			{/each}
			{:else}
			<li>Not found, try a postcode instead</li>
			{/if}
		</ul>
	</div>
	{/if}
</div>

<style>
	#select {
		text-align: left;
		padding-bottom: 5px;
	}
	a {
		text-decoration: none;
		display: block;
		padding: 0;
		border: 2px solid #00205b !important;
	}
	a span {
		display: inline-block;
		padding: 10px 5px;
	}
	.selection {
		overflow: hidden;
		max-width: calc(100% - 50px);
    white-space: nowrap;
	}
	#dropdown ul {
		list-style: none;
		background: #eee;
		margin: 0;
		margin-top: 3px;
		padding: 0;
		max-height: 260px;
		overflow-y: auto;
		overflow-x: hidden;
	}
	#dropdown li {
		line-height: 1em;
		padding: 6px;
	}
	#dropdown .highlight {
		color: #fff;
		background-color: #00205b;
		font-weight: 500;
		cursor: pointer;
	}

	small {
		color: rgb(56, 120, 197);
		font-weight: bold;
	}

	#dropdown .highlight small {
		color: #bbb;
	}
	/* normalize the input elements, make them look like everything else */
	#select input {
		width: 100%;
		box-sizing: border-box;
		background: transparent;
		font-family: inherit;
		font-size: inherit;
		color: inherit;
		font-weight: inherit;
		line-height: inherit;
		display: inline-block;
		padding: 8px 5px;
		margin: 0;
		background-color: #fff;
		/* border: 2px solid #00205b !important; */
		border-radius: 0px;
		-webkit-appearance: none;
		-moz-appearance: none;
	}
	#select input:focus {
		outline: none;
	}
	/* custom field (drop-down, text element) styling  */
	#select {
		display: block;
		width: 100%;
		position: relative;
	}
	.active {
		z-index: 1000;
		outline: 3px solid orange;
	}
	/* the toggle is the visible part in the form */
	#toggle,
	#select input {
		line-height: inherit;
		color: #00205b;
		font-weight: 500;
		cursor: pointer;
	}
	/* drop-down list / text element */
	#dropdown {
		width: 100%;
		position: absolute;
		left: 0;
		opacity: 1;
	}
	.selected {
		color: #fff !important;
		background-color: #00205b;
	}
	/* .button {
		color: #fff;
		background-color: #00205b;
		background-repeat: no-repeat;
		background-position: center;
		display: inline-block;
		float: right;
	} */
	/* .down {
		background-image: url("/img/chevron-down.svg");
		width: 30px;
	} */
	/* .search {
		background-image: url("/img/search.svg");
		width: 30px;
	} */
	.close {
		background-image: url("/img/x-close.svg");
		width: 30px;
	}
	small {
		margin-left: 3px;
	}
	/* #toggle small {
		color: lightgrey;
	} */
	#dropdown small {
		/* font-weight: bold; */
	}

	.highlight .view {
		text-decoration: underline;
	}
</style>