<script>
    export let place;
    export let storage = localStorage;

    import { base, assets } from "$app/paths";
    import { onMount } from "svelte";

    let name;

    function check_result() {
        return storage.hasOwnProperty("search_name");
    }

    function result_text () {
        name = storage.search_name;
        storage.removeItem("search_name");
        return true;
    };

    let SDZ_name;
    let SDZ_code;    
    let DZ_name; 
    let DZ_code;

    onMount(() => {
        setInterval(function() {
            if (check_result() & storage.search_code == place.code) {
                name = storage.search_name;
                result_text();
            };
        }, 500)
    })

    function lookupPostcode (postcode) {

        let search_code = postcode.replaceAll(" ", "");

        fetch("https://raw.githubusercontent.com/NISRA-Tech-Lab/local-stats/main/search_data/CPD_LIGHT_JULY_2024.csv")
            .then((response) => response.text())
            .then((data) => {
                const rows = data.split("\n");
                let code_match;

                for (let i = 0; i < rows.length; i ++) {

                    let columns = rows[i].split(",");
                    if (columns[0] == search_code) {
                        code_match = columns;
                        break
                    }
                }

                SDZ_name = code_match[21];
                SDZ_code = code_match[20];
                DZ_name = code_match[19];
                DZ_code = code_match[18];
            })

        return true;
    }

    
</script>

{#if check_result() & storage.search_code == place.code & result_text()}
	<div id = "search-result"><div>You searched for <strong>{name}</strong>.</div>
    {#if name.substr(0, 2).toUpperCase() == "BT" & lookupPostcode(name)}
        <div style = "margin-left: 1em">This postcode is located within the <strong>{place.name}</strong> District Electoral Area.</div>
        <div style = "margin-left: 1em">You can view more localised information for this postcode at Super Data Zone level by selecting <strong><a href = "{base}/{SDZ_code}">{SDZ_name}</a></strong> or at Data Zone level by selecting <strong><a href = "{base}/{DZ_code}">{DZ_name}</a></strong>. Note that many of the statistics produced are not broken down to these smaller geography levels.</div>
    {/if}
    </div>
{/if}

<style>
    #search-result {
        background-color: bisque;
        padding: 5px;
    }

    img {
        height: 40px;
        margin-right: -2px;
        filter: brightness(0) saturate(100%) invert(14%) sepia(73%) saturate(6%) hue-rotate(95deg) brightness(91%) contrast(85%);
    }
</style>