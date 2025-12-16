<script>
	import { assets } from "$app/paths";
	  import { getContext } from 'svelte';
	  export let theme = getContext('theme');
	  export let filled = true;
	//   export let center = false;
</script>
  
		<!-- <nav  style="border-bottom-color: {theme['muted']}; {filled ? 'background-color: ' +  theme['background'] + ';' : ''}">
		<div class="col-wide " style="flex-direction: row; -ms-flex-direction: row;     background-color: #00205b;" class:center>
			<a href="https://www.nisra.gov.uk/">
				<picture>
					{#if theme.name == 'dark'}
					<img style="width:180px;" src="{assets}/img/logo/nisra-only-white.svg" alt="Northern Ireland Statistics and Research Agency">
					{:else if filled == true}
					<img style="width:180px;" src="{assets}/img/logo/nisra-only-white.svg" alt="Northern Ireland Statistics and Research Agency">
					{:else}
					<img style="width:180px;" src="{assets}/img/logo/nisra-only-white.svg" alt="Northern Ireland Statistics and Research Agency">
					{/if}
				</picture>
			</a>
			<span class="text-big title;" style="color: #ffffff; padding-left: 100px" >Northern Ireland Area Explorer</span>

		</div>
	</nav> -->
  
			<nav class="nisra-header">
				<div class="header-inner" data-analytics="header">
					<a class="brand" href="https://www.nisra.gov.uk/">
					<img
						class="logo"
						src="{assets}/img/logo/nisra-only-white.svg"
						alt="Northern Ireland Statistics and Research Agency"
					/>
					</a>

					<div class="header-text">
					<h1 class="header-title">Northern Ireland Local Statistics Explorer</h1>
					<span class="header-subtitle">Find out how your local area compares to NI</span>
					</div>
				</div>
				</nav>

  <style>

.nisra-header {
  background-color: #00205b;
  color: #fff;
}

.header-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 12px 12px;
  display: flex;
  align-items: center;
  justify-content: space-between; /* ✅ logo left, text right */
  gap: 400px;
}

.brand {
  display: flex;
  align-items: center;
  flex: 0 0 auto;
}

.logo {
  width: 200px;
  height: auto;
  display: block;
}

/* Right-side text */
.header-text {
  display: flex;
  flex-direction: column;
  align-items: flex-end;   /* ✅ right aligned on desktop */
  text-align: right;
  flex: 1 1 auto;
  min-width: 0;            /* ✅ allows wrapping instead of overflow */
}

.header-title {
  margin: 0 0 8px 0;
  font-size: clamp(18px, 2.2vw, 28px); /* ✅ scales nicely */
  font-weight: 700;
  line-height: 1.1;
}

.header-subtitle {
  font-size: clamp(14px, 1.8vw, 24px);
  line-height: 1.3;
}

/* ✅ Mobile: stack and centre (or switch to left if you prefer) */
@media (max-width: 700px) {
  .header-inner {
    flex-direction: column;
    align-items: flex-start;
	gap: 20px; /* ✅ small vertical gap on mobile */
  }

  .logo {
    width: 170px;
  }

  .header-text {
    align-items: flex-start;
    text-align: left;
    width: 100%;
  }
}
	  
  </style>