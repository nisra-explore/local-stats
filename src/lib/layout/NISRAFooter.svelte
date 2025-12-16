<script>
 // import { assets } from "$app/paths";
	import { getContext } from 'svelte';
	import Section from "$lib/layout/Section.svelte";


//	export let theme = getContext('theme');
</script>

<!-- svelte-ignore missing-declaration -->
<Section column="wide">
<div class="block" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(280px, 100%), 1fr)); justify-content: stretch;">
<div style="margin-left:16px; padding-right:16px;">
	<h3 style="margin-bottom:10px; line-height: 1.78;">Download</h3>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		 <a href="https://www.nisra.gov.uk/publications/census-area-explorer-2021-and-2011-data" class="link"><strong>Download</strong> Census 2011 and 2021 data from this app</a>
	</li>
  </div>
  
  <div style="margin-left:16px; padding-right:16px;">
	<h3 style="margin-bottom:10px; line-height: 1.78;">Contact and further resources</h3>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/contacts/census-customer-services">Contact Census</a>
  	</li>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/statistics/census/2021-census">Census 2021</a>
  	</li>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/statistics/2021-census/results">Census 2021 results</a>
  	</li>
	<li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/publications/census-2021-statistical-bulletins">Statistical Bulletins</a>
  	</li>
	  <li style="margin: 0px; display: block; line-height: 20px; padding-bottom: 5px">
		<a href="https://www.nisra.gov.uk/publications/census-2021-infographics">Infographics</a>
  	</li>
	
  </div>

  <div style="margin-left:16px;">
	<h3 style="margin-bottom:10px; line-height: 1.78;">About this app</h3>
	This web application is based on and inspired by the <a href="https://github.com/ONSvisual">ONS Digital Content team prototypes</a>. 
	It has been modified by NISRA and released as a prototype to explore Census data for Northern Ireland. We welcome feedback from users through our short <a href="https://consultations2.nidirect.gov.uk/dof/area-explorer-feedback/">survey</a>.
		
  </div>

  </div>
</Section>
  
<footer class="nisra-footer">
  <div class="footer-container">
    <div class="footer-row">

      <!-- Data Tools Column -->
      <div class="footer-col">
        <h3 style="color: #fff; font-size: 15px; font-weight: normal; margin-top: 0;">Data Tools</h3>
        <ul class="footer-list">
          <li><a href="https://explore.nisra.gov.uk/local-stats/">Local Statistics Explorer</a></li>
          <li><a href="https://data.nisra.gov.uk">Data Portal</a></li>
          <li><a href="https://build.nisra.gov.uk/en/">Census Flexible Table Builder</a></li>
        </ul>
      </div>

      <!-- Corporate Column -->
      <div class="footer-col">
        <h3 style="color: #fff; font-size: 15px; font-weight: normal; margin-top: 0;">Corporate</h3>
        <ul class="footer-list">
          <li><a href="https://www.nisra.gov.uk/">NISRA Website</a></li>
          <li><a href="https://www.nisra.gov.uk/statistics/about-nisra/careers">Careers</a></li>
          <li><a href="https://www.nisra.gov.uk/contact">Contact</a></li>
        </ul>
      </div>

      <!-- Follow NISRA Column -->
      <div class="footer-col">
        <h3 style="color: #fff; font-size: 15px; font-weight: normal; margin-top: 0;">Follow NISRA</h3>
        <ul class="footer-social">
          <li>
            <a href="https://www.facebook.com/nisra.gov.uk">
              <img src="img/logo/facebook-brands-solid-full.svg" title="Facebook" role="img" class="img" />
            </a>
          </li>
          <li>
            <a href="https://x.com/NISRA/">
              <img src="img/logo/x-twitter-brands-solid-full.svg" title="Twitter/X" role="img" class="img" />
            </a>
          </li>
          <li>
            <a href="https://www.youtube.com/user/nisrastats">
              <img src="img/logo/youtube-brands-solid-full.svg" title="YouTube" role="img" class="img" />
            </a>
          </li>
          <li>
            <a href="https://www.linkedin.com/company/northern-ireland-statistics-and-research-agency/">
              <img src="img/logo/linkedin-in-brands-solid-full.svg" title="LinkedIn" role="img" class="img" />
            </a>
          </li>
        </ul>
      </div>

    </div>

    <!-- Horizontal list with separators -->
    <ul class="footer-links">
      <li><a href="https://www.nisra.gov.uk/crown-copyright">© Crown Copyright</a></li>
      <li>|</li>
      <li><a href="https://www.nisra.gov.uk/terms-and-conditions">Terms and conditions</a></li>
      <li>|</li>
      <li><a href="https://www.nisra.gov.uk/cookies">Cookies</a></li>
      <li>|</li>
      <li><a href="https://www.nisra.gov.uk/nisra-privacy-notice">Privacy</a></li>
      <li>|</li>
      <li>
        <a href="https://datavis.nisra.gov.uk/dissemination/accessibility-statement-visualisations.html" 
           rel="noopener external">Accessibility Statement</a>
      </li>
    </ul>

  </div>
</footer>

<style>
/* ===========================
   Footer Wrapper
   =========================== */
.nisra-footer {
  background-color: #00205B;
  color: #fff;
  border-top: 4px solid #3878c5;
  padding: 2rem 0 2.5rem; /* extra bottom padding for Back to top bar */
  margin-top: 1rem;
  font-family: Arial, sans-serif;
}

/* Container */
.footer-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* ===========================
   Columns Row
   =========================== */
.footer-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;   /* 🔹 keep the whole group centered */
  gap: 2rem 11rem;            /* row-gap | column-gap */
  margin-bottom: 2rem;
}

/* Columns: centred, fixed-ish width so spacing is consistent */
.footer-col {
  flex: 0 1 50px;           /* max ~260px wide, can shrink if needed */
  min-width: 250px;          /* but don't get too tiny */
}

/* Phones — stack vertically */
@media (max-width: 600px) {
  .footer-row {
    flex-direction: column;
    align-items: flex-start; /* left-align content on small screens */
    gap: 1.5rem;
  }

  .footer-col {
    flex: 1 1 100%;
  }

  .nisra-footer {
    padding-bottom: 5rem;    /* extra for Back to top bar on tiny screens */
  }
}

/* ===========================
   Headings
   =========================== */
.footer-col h3 {
  margin: 0 0 1rem 0;
  font-size: 15px;
  font-weight: normal;
  color: #fff;
}

/* ===========================
   Lists
   =========================== */
.nisra-footer ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.footer-list li {
  margin: 0 0 0.75rem 0;
}

.footer-list a {
  font-size: 18px;
  color: #fff;
  text-decoration: underline;
  text-underline-offset: 3px;
}

/* ===========================
   Social Icons
   =========================== */
.footer-social {
  display: flex;
  gap: 1rem;
}

.footer-social img {
  width: 50px;
  height: 50px;
  object-fit: contain;
  transition: box-shadow 0.2s ease, border 0.2s ease;
}

.footer-social img:hover {
  border: 2px solid #fff;
  box-shadow: 0 0 4px rgba(255,255,255,0.6);
  border-radius: 4px;
}

/* ===========================
   Bottom Links
   =========================== */
.footer-links {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-wrap: nowrap;       /* one line on larger screens */
  gap: 0.75rem;
  font-size: 18px;
  margin: 1.5rem 0 0;
  padding: 0;
}

.footer-links li {
  white-space: nowrap;
}

.footer-links a {
  color: #fff;
  font-size: 18px;
  text-decoration: underline;
}

/* Tablets — allow wrapping if needed */
@media (max-width: 900px) {
  .footer-links {
    flex-wrap: wrap;
    justify-content: center;
    text-align: center;
  }
}

/* Small phones — normal text wrapping, left aligned */
@media (max-width: 480px) {
  .footer-links {
    justify-content: flex-start;
    text-align: left;
  }

  .footer-links li {
    white-space: normal;
  }
}
</style>