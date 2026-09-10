import{$ as e,A as t,G as n,I as r,O as i,P as a,Q as o,X as s,Z as c,_t as l,c as u,et as d,ft as f,gt as p,l as m,p as h,pt as g,s as _,tt as v}from"../chunks/B-Eox4si.js";import{f as y,l as b}from"../chunks/Dxr5TczR.js";import"../chunks/xihTtKlq.js";import{t as x}from"../chunks/CRR2Z_WG.js";var S=t(`<body><div class="row"><div class="container div-grey-box"><h2>Enter your postcode to find its location</h2> <form><input type="text" placeholder="Enter postcode..."/> <button><img alt="Search button" width="40px"/></button></form> <div></div></div></div></body> <style>form {
			position: relative;
			display: inline-block;
			width: 100%;
			margin-top: 15px;
		}

		.container {
			max-width: 600px;
			margin: 0 auto;
			padding: 20px;
		}

		h2 {
			text-align: left;
			color: #333;
			font-size: 1.5em;
			line-height: 1.3;
			margin: 0px 
		}

		input[type="text"] {
			width: 100%;
			padding: 10px 40px 10px 10px;
			margin-bottom: 10px;
			border: 2px solid #00205b !important;
			border-radius: 0px;
			background-color: #f5f5f6;
			color: #00205b;
		}

		input[type="text"]:focus-visible {
			border: 2px solid #00205b;
			border-radius: 0px;
		}

		button {
			background-color: #00205b;
			background-repeat: no-repeat;
			border-radius: 0px;
			color: #fff;
			border: none;
			cursor: pointer;
			position: absolute;
			top: 0;
			right: 0;
			padding: 0px;
			width: 40px;
			height: 46px;
		}

		button:focus {
			background-color: #00205b;
		}


		#result {
			margin-top: 20px;
			padding: 10px;
			border: 1px solid #ddd;
			border-radius: 4px;
		}</style>`,1),C=t(`<nav><a>Home</a></nav> <!>`,1);function w(t,w){g(w,!1);let T=e(),E=e();function D(e){return e.replace(/\s/g,``).toUpperCase()}function O(){let e=D(r(T).value);if(e===``){alert(`Please enter a postcode.`);return}fetch(`https://raw.githubusercontent.com/nisra-explore/local-stats/main/search_data/CPD_LIGHT_JULY_2024.csv`).then(e=>e.text()).then(t=>{let n=t.split(`
`),i=!1,a=`<p>`,o=`<ul>`,s=`<ul>`;n.forEach(t=>{let n=t.split(`,`),r=D(n[0]);if(r===e){let e=n[4].trim(),t=n[5].trim();n[6].trim();let c=n[7].trim(),l=n[8].trim(),u=n[9].trim();n[10].trim();let d=n[11].trim(),f=n[23].trim(),p=n[17].trim(),m=n[18].trim(),h=n[19].trim(),g=n[20].trim(),_=n[21].trim(),v=n[30].trim(),b=n[31].trim();a+=`<strong>Postcode:</strong> ${r.slice(0,-3)} ${r.substr(-3)}`,o+=`<li><strong>Local Government District:</strong> <a href="${y}/${e}" target="_blank">${t}</a></li>
										 <li><strong>District Electoral Area:</strong> <a href="${y}/${l}" target="_blank">${u}</a></li>
										 <li><strong>Super Data Zone:</strong> <a href="${y}/${g}" target="_blank">${_}</a></li>
										 <li><strong>Data Zone:</strong> <a href="${y}/${m}" target="_blank">${h}</a></li>`,s+=`<li><strong>Urban / Rural:</strong> ${b}</li>
										  <li><strong>Settlement:</strong> ${v}</li>
										  <li><strong>Health and Social Care Trust:</strong> ${p}</li>
										  <li><strong>Assembly Area Name (2008):</strong> ${d}</li>
										  <li><strong>Assembly Area Name (2024):</strong> ${f}</li>
										  <li><strong>Ward Name:</strong> ${c}</li>`,i=!0}}),a+=`</p>`,o+=`</ul>`,s+=`</ul>`,i?d(E,r(E).innerHTML=a+`<p>Geographies in Northern Ireland Local Statistics Explorer</p>`+o+`<p>Geographies not in Northern Ireland Local Statistics Explorer</p>`+s):d(E,r(E).innerHTML=`Postcode not found.`)}).catch(e=>{console.error(`Error fetching data:`,e),alert(`Error fetching data. Please try again.`)})}_();var k=C(),A=c(k),j=s(A);l(A),x(o(A,2),{column:`wide`,children:(e,t)=>{var d=S(),f=c(d),g=s(f),_=s(g),y=o(s(_),2),x=s(y);m(x,e=>v(T,e),()=>r(T));var C=o(x,2),w=s(C);l(C),l(y),m(o(y,2),e=>v(E,e),()=>r(E)),l(_),l(g),l(f),p(2),n(e=>h(w,`src`,e),[()=>b(`/img/search.svg`)]),a(`click`,C,O),a(`submit`,y,u(O)),i(e,d)},$$slots:{default:!0}}),n(()=>h(j,`href`,`${y??``}/`)),i(t,k),f()}export{w as component};