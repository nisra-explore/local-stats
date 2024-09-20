import { getData } from "$lib/utils";
import { 
  app_inputs,
  geog_types 
} from "$lib/config";

// async function loadArea(code, fetch) {
//     let res = await fetch(app_inputs.app_json_data + code + ".json");
//     let json = await res.json();

//     return json;
// }

export async function load({ fetch }) {
    // let code = params.code;
    
    let res = await getData(app_inputs.search_data, fetch);
    
    let lookup = {};
    res.forEach((d) => (lookup[d.code] = d.name));
    res.forEach((d) => {
        d.typepl = geog_types[d.type].pl;
        d.typenm = geog_types[d.type].name;
        //		  d.typestr = lookup[d.parent] ? `${lookup[d.parent]} includes ${types[d.type].name} within ${lookup[d.parent]}` : '';
        d.typestr = lookup[d.parent]  && d.parent == d.code
        ? `View:  ${lookup[d.parent]}
        ${geog_types[d.parent_type].name}  `
            : lookup[d.parent]  && d.parent != d.code
            ? `${geog_types[d.type].name} `
            : "";
    });

    let search_data = res.sort((a, b) => a.name.localeCompare(b.name));
    // let ni = await loadArea("N92000002", fetch);
    // let place = await loadArea(code, fetch);
    // console.log(search_data, place, ni)
    return {
        search_data
    };

}