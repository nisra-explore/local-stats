import { app_inputs } from "$lib/config";

export async function load({ fetch }) {
	let new_datasets = [];

	try {
		const metadataResponse = await fetch(
			`${app_inputs.app_json_data}N92000002.json`
		);

		if (!metadataResponse.ok) {
			throw new Error(`Metadata request failed: ${metadataResponse.status}`);
		}

		const ni_data = await metadataResponse.json();
		const metadataRows = Object.values(ni_data.meta_data ?? {}).flat();
		const seenDatasetIds = new Set();

		new_datasets = metadataRows
			.filter(
				(record) =>
					record &&
					record.title &&
					record.last_updated &&
					record.dataset_url &&
					!Number.isNaN(Date.parse(record.last_updated))
			)
			.sort(
				(first, second) =>
					new Date(second.last_updated) - new Date(first.last_updated)
			)
			.filter((record) => {
				const datasetId = record.table_code || record.dataset_url;
				if (seenDatasetIds.has(datasetId)) return false;
				seenDatasetIds.add(datasetId);
				return true;
			})
			.slice(0, 5);
	} catch (error) {
		console.error("Could not load new datasets metadata", error);
	}

	return { new_datasets };
}
