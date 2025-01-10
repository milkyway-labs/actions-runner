#!/bin/bash

if [ "$RUNNER_ALLOW_RUNASROOT" != "1" ]; then
	echo "Error: RUNNER_ALLOW_RUNASROOT is not set to 1."
	exit 1
fi

if [ -z "$PAT" ]; then
	echo "Error: PAT is not set."
	exit 1
fi

if [ -z "$ORG" ]; then
	echo "Error: ORG is not set."
	exit 1
fi

run() {
	token=$(
		curl -s -L \
			-X POST \
			-H "Accept: application/vnd.github+json" \
			-H "Authorization: Bearer ${PAT}" \
			-H "X-GitHub-Api-Version: 2022-11-28" \
			https://api.github.com/orgs/${ORG}/actions/runners/registration-token \
			| jq -r .token
	)

	./config.sh --unattended --url https://github.com/${ORG} --token $token --ephemeral

	./run.sh
}

cleanup() {
	runner_ids=$(
		curl -s -L \
			-H "Accept: application/vnd.github+json" \
			-H "Authorization: Bearer ${PAT}" \
			-H "X-GitHub-Api-Version: 2022-11-28" \
			https://api.github.com/orgs/${ORG}/actions/runners \
			| jq -r '.runners[].id'
	)

	runner_len=$(echo "$runner_ids" | wc -l)
	echo "Detected $runner_len runners."

	if [ $runner_len -ge 2 ]; then
		for runner_id in $runner_ids; do
			curl -s -L \
				-X DELETE \
				-H "Accept: application/vnd.github+json" \
				-H "Authorization: Bearer ${PAT}" \
				-H "X-GitHub-Api-Version: 2022-11-28" \
				https://api.github.com/orgs/${ORG}/actions/runners/${runner_id}
		done

		echo "Cleaned up $runner_len runners."
	fi
}

echo "Trying to cleanup runners..."
cleanup

echo "Starting runner..."
run
