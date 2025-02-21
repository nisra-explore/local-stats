import{s as j,f as d,a as D,g as u,r as w,c as N,i as S,d as m,h as M,j as k,u as p,y as I,z as q,v as W,A as F,p as P}from"../chunks/scheduler.a2c9abeb.js";import{S as J,i as K,b as Q,d as X,m as tt,a as rt,t as nt,e as et}from"../chunks/index.49c2d5c7.js";import{S as ot}from"../chunks/Section.985dde47.js";import{b as y}from"../chunks/paths.66e70025.js";function st(l){let s,i,n,t,f="Enter your postcode to find its location",r,a,o,g,h,L=`<img src="${y}/img/search.svg" alt="Search button" width="40px"/>`,E,b,x,_,e=`form {\r
			position: relative;\r
			display: inline-block;\r
			width: 100%;\r
			margin-top: 15px;\r
		}\r
\r
		.container {\r
			max-width: 600px;\r
			margin: 0 auto;\r
			padding: 20px;\r
		}\r
\r
		h2 {\r
			text-align: left;\r
			color: #333;\r
			font-size: 1.5em;\r
			line-height: 1.3;\r
			margin: 0px \r
		}\r
\r
		input[type="text"] {\r
			width: 100%;\r
			padding: 10px 40px 10px 10px;\r
			margin-bottom: 10px;\r
			border: 2px solid #00205b !important;\r
			border-radius: 0px;\r
			background-color: #f5f5f6;\r
			color: #00205b;\r
		}\r
\r
		input[type="text"]:focus-visible {\r
			border: 2px solid #00205b;\r
			border-radius: 0px;\r
		}\r
\r
		button {\r
			background-color: #00205b;\r
			background-repeat: no-repeat;\r
			border-radius: 0px;\r
			color: #fff;\r
			border: none;\r
			cursor: pointer;\r
			position: absolute;\r
			top: 0;\r
			right: 0;\r
			padding: 0px;\r
			width: 40px;\r
			height: 46px;\r
		}\r
\r
		button:focus {\r
			background-color: #00205b;\r
		}\r
\r
\r
		#result {\r
			margin-top: 20px;\r
			padding: 10px;\r
			border: 1px solid #ddd;\r
			border-radius: 4px;\r
		}`,T,H;return{c(){s=d("body"),i=d("div"),n=d("div"),t=d("h2"),t.textContent=f,r=D(),a=d("form"),o=d("input"),g=D(),h=d("button"),h.innerHTML=L,E=D(),b=d("div"),x=D(),_=d("style"),_.textContent=e,this.h()},l(c){s=u(c,"BODY",{});var v=M(s);i=u(v,"DIV",{class:!0});var C=M(i);n=u(C,"DIV",{class:!0});var $=M(n);t=u($,"H2",{"data-svelte-h":!0}),w(t)!=="svelte-m72usz"&&(t.textContent=f),r=N($),a=u($,"FORM",{});var A=M(a);o=u(A,"INPUT",{type:!0,placeholder:!0}),g=N(A),h=u(A,"BUTTON",{"data-svelte-h":!0}),w(h)!=="svelte-17jdzgh"&&(h.innerHTML=L),A.forEach(m),E=N($),b=u($,"DIV",{}),M(b).forEach(m),$.forEach(m),C.forEach(m),v.forEach(m),x=N(c),_=u(c,"STYLE",{"data-svelte-h":!0}),w(_)!=="svelte-sybcd5"&&(_.textContent=e),this.h()},h(){k(o,"type","text"),k(o,"placeholder","Enter postcode..."),k(n,"class","container div-grey-box"),k(i,"class","row")},m(c,v){S(c,s,v),p(s,i),p(i,n),p(n,t),p(n,r),p(n,a),p(a,o),l[3](o),p(a,g),p(a,h),p(n,E),p(n,b),l[4](b),S(c,x,v),S(c,_,v),T||(H=[I(h,"click",l[2]),I(a,"submit",q(l[2]))],T=!0)},p:W,d(c){c&&(m(s),m(x),m(_)),l[3](null),l[4](null),T=!1,F(H)}}}function at(l){let s,i=`<a href="${y}/">Home</a>`,n,t,f;return t=new ot({props:{column:"wide",$$slots:{default:[st]},$$scope:{ctx:l}}}),{c(){s=d("nav"),s.innerHTML=i,n=D(),Q(t.$$.fragment)},l(r){s=u(r,"NAV",{"data-svelte-h":!0}),w(s)!=="svelte-lbvmqv"&&(s.innerHTML=i),n=N(r),X(t.$$.fragment,r)},m(r,a){S(r,s,a),S(r,n,a),tt(t,r,a),f=!0},p(r,[a]){const o={};a&35&&(o.$$scope={dirty:a,ctx:r}),t.$set(o)},i(r){f||(rt(t.$$.fragment,r),f=!0)},o(r){nt(t.$$.fragment,r),f=!1},d(r){r&&(m(s),m(n)),et(t,r)}}}function U(l){return l.replace(/\s/g,"").toUpperCase()}function it(l,s,i){let n,t;function f(){const o=U(n.value);if(o===""){alert("Please enter a postcode.");return}fetch("https://raw.githubusercontent.com/nisra-explore/local-stats/main/search_data/CPD_LIGHT_JULY_2024.csv").then(g=>g.text()).then(g=>{const h=g.split(`
`);let L=!1,E="<p>",b="<ul>",x="<ul>";h.forEach(_=>{const e=_.split(","),T=U(e[0]);if(T===o){const H=e[4].trim(),c=e[5].trim();e[6].trim();const v=e[7].trim(),C=e[8].trim(),$=e[9].trim();e[10].trim();const A=e[11].trim(),R=e[23].trim(),Z=e[17].trim(),G=e[18].trim(),z=e[19].trim(),V=e[20].trim(),B=e[21].trim(),O=e[30].trim(),Y=e[31].trim();E+=`<strong>Postcode:</strong> ${T.slice(0,-3)} ${T.substr(-3)}`,b+=`<li><strong>Local Government District:</strong> <a href="${y}/${H}" target="_blank">${c}</a></li>
										 <li><strong>District Electoral Area:</strong> <a href="${y}/${C}" target="_blank">${$}</a></li>
										 <li><strong>Super Data Zone:</strong> <a href="${y}/${V}" target="_blank">${B}</a></li>
										 <li><strong>Data Zone:</strong> <a href="${y}/${G}" target="_blank">${z}</a></li>`,x+=`<li><strong>Urban / Rural:</strong> ${Y}</li>
										  <li><strong>Settlement:</strong> ${O}</li>
										  <li><strong>Health and Social Care Trust:</strong> ${Z}</li>
										  <li><strong>Assembly Area Name (2008):</strong> ${A}</li>
										  <li><strong>Assembly Area Name (2024):</strong> ${R}</li>
										  <li><strong>Ward Name:</strong> ${v}</li>`,L=!0}}),E+="</p>",b+="</ul>",x+="</ul>",L?i(1,t.innerHTML=E+"<p>Geographies in Northern Ireland Local Statistics Explorer</p>"+b+"<p>Geographies not in Northern Ireland Local Statistics Explorer</p>"+x,t):i(1,t.innerHTML="Postcode not found.",t)}).catch(g=>{console.error("Error fetching data:",g),alert("Error fetching data. Please try again.")})}function r(o){P[o?"unshift":"push"](()=>{n=o,i(0,n)})}function a(o){P[o?"unshift":"push"](()=>{t=o,i(1,t)})}return[n,t,f,r,a]}class ut extends J{constructor(s){super(),K(this,s,it,at,j,{})}}export{ut as component};
