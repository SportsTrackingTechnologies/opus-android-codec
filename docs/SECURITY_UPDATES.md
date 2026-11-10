# Opus security update procedure

Review upstream Opus releases and security advisories on a regular cadence.
For each candidate update, record the upstream commit, rebuild every supported
ABI, run decoder regression tests, and publish a new SDK version. Do not
replace an existing release artifact in place.
