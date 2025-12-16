# NISRA Local Stats Explorer
An explorer for NISRA's key statistics

This is a development repo. Final releases will be via a public repo.

## Building and Deploying the explorer

Run `npm run dev` to ensure your most recent changes are ok locally

Run `npm run build` to compile the app and create a build folder

Run `npm run preview` to try compiling the app from the build folder. Some paths can be messed up in preview but provided they work ok in dev it should be fine. The main thing to check is the structure and functionality of the app

If happy with the preview then run `npm run deploy` to push your build folder to Github Pages. A message will be posted to the console to confirm successful publishing. After a short period of time, the new Deployment should appear in the Deployments page of your repo on Github (https://github.com/NISRA-Tech-Lab/local-stats/deployments). The code pushed to deployments is held in a branch of the repo named gh-pages.
## Instructions for changing prerender of app

The current setup of the app is to not prerender each of the `[code]/+page.svelte` files to html. This can be changed to prerender by changing code in the following places:

- in `+layout.js`, uncomment the `export const prerender = true;` line
- in `svelte.config.js`, uncomment `prerender: { entries: ["*"]},`
- in `svelte.config.js`, swap the arguments for `paths.base` just below the previous entries option


