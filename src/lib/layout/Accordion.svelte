<script>
    import { base } from "$app/paths";
    import GreyBox from "$lib/layout/GreyBox.svelte";

    export let id;
    export let img;
    export let heading;
    export let place;
    export let sub_heading;
    export let description;
    export let boxes;
    export let more;
    export let chart_compare_type;

    let box_list = Object.keys(boxes);
    let w, cols;
    
    // State to manage visibility of "More Statistics"
    let moreStatsVisible = false;

    // Toggle function for "More Statistics"
    const toggleMoreStats = () => {
        moreStatsVisible = !moreStatsVisible;
    };
</script>

<div class="accordion-item">
    <h2 class="accordion-header" id="panelsStayOpen-heading{id}">
        <button
            class="accordion-button collapsed"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#panelsStayOpen-collapse{id}"
            aria-expanded="false"
            aria-controls="panelsStayOpen-collapse{id}"
        >
            <span class="accordion-button-title">
                <img
                    src="{base}/img/{img}"
                    alt="logo"
                    height="40"
                    class="accordion-dept-logo"
                />
                {heading}</span>
        </button>
    </h2>

    <div
        id="panelsStayOpen-collapse{id}"
        class="accordion-collapse collapse"
        aria-labelledby="panelsStayOpen-heading{id}"
    >
        <div class="accordion-body">
            {place.name}. {@html sub_heading}
            <!-- {place.name} {place.type.toLocaleUpperCase()}. {@html sub_heading} -->
            <span class="accordion-button-title-sub">{description}</span>

            <div class="grid mt" bind:clientWidth={w}>
                {#each {length: box_list.length} as _, i}
                    {#if (boxes[box_list[i]].hasOwnProperty("show") && boxes[box_list[i]].show.includes(place.type))}
                        <GreyBox
                            id={boxes[box_list[i]].id}
                            style={boxes[box_list[i]].style}
                            place={place}
                            year={boxes[box_list[i]].year}
                            content={boxes[box_list[i]].content}
                            chart_data={boxes[box_list[i]].chart_data}
                            zKey={boxes[box_list[i]].zKey}
                            label={boxes[box_list[i]].label}
                            topic_prev_available={boxes[box_list[i]].topic_prev_available}
                            chart_compare_type={chart_compare_type}
                            i_button={boxes[box_list[i]].i_button}
                            heading={boxes[box_list[i]].title}
                            compare_content={boxes[box_list[i]].compare_content}
                        />
                    {/if}

                    {#if (!boxes[box_list[i]].hasOwnProperty("show"))}
                        <GreyBox
                            id={boxes[box_list[i]].id}
                            style={boxes[box_list[i]].style}
                            place={place}
                            year={boxes[box_list[i]].year}
                            content={boxes[box_list[i]].content}
                            chart_data={boxes[box_list[i]].chart_data}
                            zKey={boxes[box_list[i]].zKey}
                            label={boxes[box_list[i]].label}
                            topic_prev_available={boxes[box_list[i]].topic_prev_available}
                            chart_compare_type={chart_compare_type}
                            i_button={boxes[box_list[i]].i_button}
                            compare_content={boxes[box_list[i]].compare_content}
                        />
                    {/if}
                {/each}
            </div>

            {#if more != ""}
                <!-- Button to toggle visibility of "More Statistics" with + or - sign -->
                <h3>
                    More {heading.toLocaleLowerCase()} statistics
                    <button class="btn-toggle-more-stats" on:click={toggleMoreStats}>
                          <span class="text-small">{moreStatsVisible ? "- Click to hide" : "+ Click to expand"}</span>
                    </button>
                </h3>
                
                <!-- Expandable content -->
                {#if moreStatsVisible}
                    <div class="accordion-more">{@html more}</div>
                {/if}
            {/if}
        </div>
    </div>
</div>

<style>
    .accordion-more {
        margin-top: 1em;
    }

    .btn-toggle-more-stats {
        background-color: transparent;
        border: none;
        color:  rgb(0,100,200);
        text-decoration: underline;
        cursor: pointer;
        font-size: 1.2rem;
        margin-top: 10px;
    }

    .btn-toggle-more-stats:hover {

        text-decoration: underline;
        text-decoration-color:  #000000;
        text-decoration-thickness: 2px;

        }


    
    .btn-toggle-more-stats:visited {
        color: purple;
    }

    .grid {
        display: grid;
        width: 100%;
        grid-gap: 10px;
        grid-template-columns: repeat(auto-fit, minmax(min(280px, 100%), 1fr));
        justify-content: stretch;
        page-break-inside: avoid;
    }

    .mt {
        margin-top: 20px;
    }
</style>
