<script>
    export let buttonVisibleOnPX = 200;
    let hidden = true;

    const goStart = () => {
        document.body.scrollIntoView();
    };

    const scrollElement = () => {
        return document.documentElement || document.body;
    };

    const handleOnScroll = () => {
        if (scrollElement().scrollTop > buttonVisibleOnPX) {
            hidden = false;
        } else {
            hidden = true;
        }
    };
</script>

<svelte:window on:scroll={handleOnScroll} />

<div role = "region" class="back_to_start" on:click={goStart} class:hidden><a href="#" tabindex="0">Back to top</a></div>

<style>
    .back_to_start {
        opacity: 1;
        transition: opacity 0.5s, visibility 0.5s;
        position: fixed;
        z-index: 99;
        right: 0px;
        user-select: none;
        bottom: 0px;
        color: #00205b;
        background-color: rgba(170, 170, 170);
        width: 100%;
        text-align: center;
        padding-top: 5px;
        padding-bottom: 5px;
        font-weight: 700;
        cursor: pointer;
        overflow: auto;
    }

    a {
        color: #00205b;             
    }

    .back_to_start.hidden {
        opacity: 0;
        visibility: hidden;
    }
</style>