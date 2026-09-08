<script>
  import { base } from "$app/paths";
</script>

<nav class="warning">
  <div class="text-white text-center py-2 px-3">
    <strong>We welcome feedback from users through our
      <a 
      class="survey-link"
      href="https://dttselfserve.nidirect.gov.uk/NISRA/RateIt#/Data_Explorer" 
      target="_blank" 
      rel="noopener" 
      title="RateIt Survey (opens in new tab)">short survey
      </a>
    </strong>
  </div>
</nav>

<style>
  .warning {
    color: white;
    background-color: #3878c5;
    margin-bottom: 0px;
    padding: 10px 0;
    font-size: 1em;
    text-align: center;
  }

.survey-link,
.survey-link:visited,
.survey-link:hover {
  color: #ffffff;
  text-decoration-color: #ffffff;
}

nav a[target="_blank"]::after {
  content: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="14" height="11" viewBox="0 0 14 11"><g fill="none" stroke="white" stroke-width="1"><path d="M0 3h2V0h12v8h-2v3H0zm13-2H3v6h10zM2 4H1v4h1zm-1 6h10V8H1z"/></g></svg>');
  display: inline-block;
  width: 14px;
  height: 11px;
  margin: 0 5px 0 5px;
  vertical-align: text-top;
}

</style>
