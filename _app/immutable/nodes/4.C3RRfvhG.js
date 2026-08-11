import{$ as e,E as t,J as n,M as r,O as i,P as a,Q as o,U as s,X as c,Y as l,Z as u,c as d,dt as f,ht as p,l as m,mt as h,p as g,s as _,ut as v}from"../chunks/Bd2nAV20.js";import{f as y}from"../chunks/B2ueHk8h.js";import"../chunks/xihTtKlq.js";import{t as b}from"../chunks/CS8E8aPU.js";var x=i(`<body><div class="row"><div class="container div-grey-box"><h2>Enter your postcode to find its location</h2> <form><input type="text" placeholder="Enter postcode..."/> <button><img alt="Search button" width="40px"/></button></form> <div></div></div></div></body> <style>form {
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
		}</style>`,1),S=i(`<nav><a>Home</a></nav> <!>`,1);function C(i,C){f(C,!1);let w=u(),T=u();function E(e){return e.replace(/\s/g,``).toUpperCase()}function D(){let e=E(a(w).value);if(e===``){alert(`Please enter a postcode.`);return}fetch(`https://raw.githubusercontent.com/nisra-explore/local-stats/main/search_data/CPD_LIGHT_JULY_2024.csv`).then(e=>e.text()).then(t=>{let n=t.split(`
`),r=!1,i=`<p>`,s=`<ul>`,c=`<ul>`;n.forEach(t=>{let n=t.split(`,`),a=E(n[0]);if(a===e){let e=n[4].trim(),t=n[5].trim();n[6].trim();let o=n[7].trim(),l=n[8].trim(),u=n[9].trim();n[10].trim();let d=n[11].trim(),f=n[23].trim(),p=n[17].trim(),m=n[18].trim(),h=n[19].trim(),g=n[20].trim(),_=n[21].trim(),v=n[30].trim(),b=n[31].trim();i+=`<strong>Postcode:</strong> ${a.slice(0,-3)} ${a.substr(-3)}`,s+=`<li><strong>Local Government District:</strong> <a href="${y}/${e}" target="_blank">${t}</a></li>
										 <li><strong>District Electoral Area:</strong> <a href="${y}/${l}" target="_blank">${u}</a></li>
										 <li><strong>Super Data Zone:</strong> <a href="${y}/${g}" target="_blank">${_}</a></li>
										 <li><strong>Data Zone:</strong> <a href="${y}/${m}" target="_blank">${h}</a></li>`,c+=`<li><strong>Urban / Rural:</strong> ${b}</li>
										  <li><strong>Settlement:</strong> ${v}</li>
										  <li><strong>Health and Social Care Trust:</strong> ${p}</li>
										  <li><strong>Assembly Area Name (2008):</strong> ${d}</li>
										  <li><strong>Assembly Area Name (2024):</strong> ${f}</li>
										  <li><strong>Ward Name:</strong> ${o}</li>`,r=!0}}),i+=`</p>`,s+=`</ul>`,c+=`</ul>`,r?o(T,a(T).innerHTML=i+`<p>Geographies in Northern Ireland Local Statistics Explorer</p>`+s+`<p>Geographies not in Northern Ireland Local Statistics Explorer</p>`+c):o(T,a(T).innerHTML=`Postcode not found.`)}).catch(e=>{console.error(`Error fetching data:`,e),alert(`Error fetching data. Please try again.`)})}_();var O=S(),k=l(O),A=n(k);p(k),b(c(k,2),{column:`wide`,children:(i,o)=>{var u=x(),f=l(u),_=n(f),v=n(_),b=c(n(v),2),S=n(b);m(S,t=>e(w,t),()=>a(w));var C=c(S,2),E=n(C);p(C),p(b),m(c(b,2),t=>e(T,t),()=>a(T)),p(v),p(_),p(f),h(2),s(()=>g(E,`src`,`${y??``}/img/search.svg`)),r(`click`,C,D),r(`submit`,b,d(D)),t(i,u)},$$slots:{default:!0}}),s(()=>g(A,`href`,`${y??``}/`)),t(i,O),v()}export{C as component};