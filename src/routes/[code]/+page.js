
import { getData } from "$lib/utils";
import { 
  app_inputs,
  geog_types 
} from "$lib/config";

async function loadArea(code, fetch) {
    let res = await fetch(app_inputs.app_json_data + code + ".json");
    let json = await res.json();

    return json;
}

// Geography levels offered in the comparison selector. "lgd" = councils.
const COMPARE_TYPES = ["lgd"];
const NI_CODE = "N92000002";

export async function load({ params, fetch, url }) {
    let code = params.code;
    
    let res = await getData(app_inputs.search_data, fetch);
    
    let lookup = {};
    res.forEach((d) => (lookup[d.code] = d.name));
    res.forEach((d) => {
        d.typepl = geog_types[d.type].pl;
        d.typenm = geog_types[d.type].name;
        //		  
        // d.typestr = lookup[d.parent] 
        //         ? `${lookup[d.parent]} includes ${geog_types[d.type].name} within ${lookup[d.parent]}` 
        //         : '';
        d.typestr = lookup[d.parent]  && d.parent == d.code
        ? `View:  ${lookup[d.parent]}
        ${geog_types[d.parent_type].name}  `
            : lookup[d.parent]  && d.parent != d.code
            ? `${geog_types[d.type].name} `
            : "";


});

    let search_data = res.sort((a, b) => a.name.localeCompare(b.name));
    // NI first, then every area whose type is in COMPARE_TYPES.
    // search_data is already sorted by name on the line above.
    let compare_options = [
        ...search_data
            .filter((d) => COMPARE_TYPES.includes(d.type))
            .map((d) => ({ code: d.code, name: d.name }))
    ];

    // Read ?compare= from the address; ignore anything not on the list.
    let compare_code = url.searchParams.get("compare");
    if (!compare_options.some((d) => d.code == compare_code)) {
        compare_code = NI_CODE;
    }

    let place = await loadArea(code, fetch);

    // Rule: only a council may be compared, and only with another council.
    // Any other geography falls back to the Northern Ireland default.
    if (place.type != "lgd") compare_code = NI_CODE;

    let ni = await loadArea(compare_code, fetch);


    return {
        search_data, place, ni, compare_options, compare_code
    };

}