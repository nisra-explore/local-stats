<script>
  import { onMount } from "svelte";

  export let analyticsId;
  export let analyticsProps = {};
  export let usageCookies = false;
  export let page = null;

  let live;
  let showBanner = false;
  let showConfirm = false;
  let message = "";
  let location = null;

  const SHARED_DOMAIN = ".nisra.gov.uk";
  const DATA_EXPLORER_COOKIE = "cookie-agreed";
  const ACCEPTED = "2";
  const REJECTED = "0";

  function getCookie(name) {
    const match = document.cookie.match(
      new RegExp("(^|; )" + name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "=([^;]*)")
    );
    return match ? decodeURIComponent(match[2]) : null;
  }

  function hasCookiesPreferencesSet() {
    return document.cookie.indexOf("cookies_preferences_set=true") > -1;
  }

  function getUsageCookieValue() {
    const cookiesPolicyCookie = document.cookie.match(
      new RegExp("(^|;) ?cookies_policy=([^;]*)(;|$)")
    );

    if (cookiesPolicyCookie) {
      const decodedCookie = decodeURIComponent(cookiesPolicyCookie[2]);
      const cookieValue = JSON.parse(decodedCookie);
      return cookieValue.usage;
    }

    return false;
  }

  function setCookie(option, silent = false) {
    const oneYearInSeconds = 60 * 60 * 24 * 365;
    const cookiesDomain = SHARED_DOMAIN;
    const cookiesPreference = true;
    const encodedCookiesPolicy =
      `%7B%22essential%22%3Atrue%2C%22usage%22%3A${option === "all" ? "true" : "false"}%7D`;
    const cookiesPath = "/";

    document.cookie =
      `cookies_preferences_set=${cookiesPreference};max-age=${oneYearInSeconds};domain=${cookiesDomain};path=${cookiesPath};Secure;SameSite=Lax`;
    document.cookie =
      `cookies_policy=${encodedCookiesPolicy};max-age=${oneYearInSeconds};domain=${cookiesDomain};path=${cookiesPath};Secure;SameSite=Lax`;

    usageCookies = option === "all";

    if (!silent) {
      message = option === "all" ? "all" : "only essential";
      showConfirm = true;
    }

    if (option === "all") initAnalytics();
  }

  function initAnalytics() {
    console.log("initialising analytics");

    window.dataLayer = [{
      analyticsOptOut: false,
      "gtm.whitelist": ["google", "hjtc", "lcl"],
      "gtm.blacklist": ["customScripts", "sp", "adm", "awct", "k", "d", "j"],
      ...analyticsProps
    }];

    if (page) location = $page.url.hostname + $page.url.pathname + $page.url.searchParams;

    (function(w,d,s,l,i){
      w[l]=w[l]||[];
      w[l].push({'gtm.start': new Date().getTime(), event:'gtm.js'});
      var f=d.getElementsByTagName(s)[0],
          j=d.createElement(s),
          dl=l!='dataLayer' ? '&l=' + l : '';
      j.async=true;
      j.src='https://www.googletagmanager.com/gtm.js?id=' + i + dl;
      f.parentNode.insertBefore(j,f);
    })(window, document, "script", "dataLayer", analyticsId);
  }

  onMount(() => {
    live = true;

    const sharedConsent = getCookie(DATA_EXPLORER_COOKIE);

    if (sharedConsent === ACCEPTED) {
      setCookie("all", true);
      showBanner = false;
      return;
    }

    if (sharedConsent === REJECTED) {
      setCookie("reject", true);
      showBanner = false;
      return;
    }

    showBanner = !hasCookiesPreferencesSet();
    usageCookies = getUsageCookieValue();

    if (usageCookies) {
      initAnalytics();
    }
  });
</script>

{#if showBanner}
<section style="background-color:#00205b;color:#FFF">
  <form
    id="global-cookie-message"
    class="cookies-banner clearfix"
    aria-label="cookie banner">
    {#if !showConfirm}
    <div class="cookies-banner__wrapper wrapper">
      <div>
        <div class="cookies-banner__message font-size--18">
          <h1 class="cookies-banner__heading font-size--h3">
            Cookies on the Northern Ireland Local Statistics Explorer website
          </h1>
          <p class="cookies-banner__body">
            This prototype web application places small amounts of information known as cookies on your device.
            <a href="https://www.nisra.gov.uk/cookies" class="link" style="color: #ffffff"><u>Find out more about cookies</u></a>.

          </p>
        </div>
        <div class="cookies-banner__buttons">
          <div class="cookies-banner__button cookies-banner__button--accept">
            <button
              class="btn btn--full-width btn--primary btn--focus margin-right--2 font-weight-700 font-size--17 text-wrap"
              data-gtm-accept-cookies="true" type="submit"
              on:click|preventDefault={() => setCookie('all')}>
              Accept cookies
            </button>
          </div>
          <div class="cookies-banner__button">
            <button
              class="btn btn--full-width btn--secondary btn--focus font-weight-700 font-size--17 text-wrap"
              data-gtm-accept-cookies="true"
              on:click|preventDefault={() => setCookie('reject')}>
              Reject cookies
              </button>
          </div>
        </div>
      </div>
    </div>
    {/if}
  </form>
</section>
{/if}

<style>
  .wrapper{
    width:90%;
    margin:0 auto;
    padding:0 16px;
  }
  @media(min-width:768px){
    .wrapper{
        width:90%;
        padding:0;
    }
  }
  @media(min-width:992px){
    .wrapper{
        width:90%;
        padding:0;
    }
  }
  .cookies-banner{
    padding:0px 0;
    box-sizing:border-box;
  }
  @media(max-width:768px){
    .cookies-banner{
        padding:10px 0;
    }
  }
  .cookies-banner__wrapper{
    margin-left:auto;
    margin-right:auto;
  }
  .cookies-banner__heading{
    font-weight:800;
  }
  .cookies-banner__body{
    padding:0;
  }
  .cookies-banner__buttons{
    display:flex;
    display:-ms-flexbox;
    justify-content:left;
    align-items:center;
    margin-top:1rem;
  }
  @media(max-width:768px){
    .cookies-banner__buttons{
        flex-direction:column;
        justify-content:center;
        align-items:center;
    }
  }
  .cookies-banner__button{
    display:inline-block;
    margin-right:8px;
  }
  @media(max-width:768px){
    .cookies-banner__button{
        margin-top:8px;
        margin-right:0;
        width:90%;
        display:block;
    }
  }
 /*  .cookies-banner__button--hide{
    -webkit-font-smoothing:antialiased;
    -moz-osx-font-smoothing:grayscale;
    font-weight:400;
    font-size:18px;
    line-height:1.25;
    outline:0;
    border:0;
    background:0 0;
    text-decoration:underline;
    color:#206095;
    padding:0;
    float:right;
  } */
  @media(max-width:768px){
   /*  .cookies-banner__button--hide{
        padding:1rem 0;
        display:block;
        float:none;
    } */
  }
  .cookies-banner a{
    text-decoration:none;
  }
  .cookies-banner p,.cookies-banner .markdown li p:nth-of-type(2),.markdown li .cookies-banner p:nth-of-type(2),.cookies-banner .section__content--markdown li p:nth-of-type(2),.section__content--markdown li .cookies-banner p:nth-of-type(2),.cookies-banner .section__content--static-markdown li p:nth-of-type(2),.section__content--static-markdown li .cookies-banner p:nth-of-type(2){
    padding:0;
    margin:8px 0;
  }
  .wrapper,.clearfix{  
    *zoom:1;
  }
  .wrapper:before,.clearfix:before,.wrapper:after,.clearfix:after{
    content:"";
    display:table;
  }
  .wrapper:after,.clearfix:after{
    clear:both;
  }
  .font-size--18 {
    font-size:18px;
  }
  .font-size--17{
    font-size:17px!important;
  }
  .font-size--h3{
    font-size: 21px;
    line-height: 24px;
    margin: 16px 0 0;
    padding: 3px 0 5px;
    orphans:3;
    widows:3;
  }
  button{
    cursor:pointer;
  }
  .btn{
    font-family:open sans,Helvetica,Arial,sans-serif;
    font-weight:400;
    font-size:14px;
    display:inline-block;
    width:auto;
    cursor:pointer;
    padding:6px 16px;
    border:0;
    text-align:center;
    -webkit-appearance:none;
    transition:background-color .25s ease-out;
    text-decoration:none;
    line-height:24px;
  }
  .btn--primary{
    background-color:#0f8243;
    color:#fff;
  }
  .btn--primary:hover,.btn--primary:focus{
    background-color:#0b5d30;
  }
  .btn--secondary{
    background-color:#6d6e72;
    color:#fff;
  }
  .btn--secondary:hover,.btn--secondary:focus{
    background-color:#323132;
  }
  .btn--full-width{
    display:block;
    width:100%;
  }
  .btn--focus:focus{
    -webkit-box-shadow:0 0 0 3px #f93;
    -moz-box-shadow:0 0 0 3px #f93;
    box-shadow:0 0 0 3px #f93;
    outline:0;
  }
	.margin-right--2{
		margin-right:32px!important;
	}
  .font-weight-700{
    font-weight:700!important;
  }
  .text-wrap{
    white-space:normal;
  }
</style>