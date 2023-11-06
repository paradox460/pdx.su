---
date: 2023-11-06T16:21:53-07:00
---

# CalVer for Release Drafter

Recently, I wanted to use [CalVer](https://calver.org/) with [Release Drafter](https://github.com/release-drafter/release-drafter). This is for a project where the SemVer approach would result in a perpetually increasing patch version number, and a practically frozen major and minor version. Unfortunately, Release Drafter has no inbuilt support for CalVer, so we've gotta calculate version numbers ourselves.


```js
function parseVersion(version) {
  if (!version) return;

  const regexp = /^v?(?<calVer>\d+\.\d+)\.(?<incremental>\d+)/i
  const matches = version.match(regexp);
  if (!matches) return;

  const { calVer, incremental } = matches.groups;

  return {
    calVer,
    incremental: parseInt(incremental)
  }
};

function currentCalVer() {
  const date = new Date();
  return `${date.getUTCFullYear()}.${date.getUTCMonth() + 1}`
};

module.exports = async (github, context) => {
  const calVerDate = currentCalVer();

  const latestRelease = (await github.rest.repos.getLatestRelease({ owner: context.repo.owner, repo: context.repo.repo })).data;
  const parsedVersion = parseVersion(latestRelease.tag_name);

  if (!parsedVersion) return `${calVerDate}.0`;

  if (parsedVersion.calVer === calVerDate) return `${calVerDate}.${parsedVersion.incremental + 1}`;
};
```

This script is meant to be used with Github's [actions/script](https://github.com/actions/github-script) workflow, which allows you to use JavaScript inside an Actions workflow. You'd call it something like this:

```yaml
name: Release Drafter

jobs:
  update_release_draft:
    permissions:
      contents: write
      pull-requests: read
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: "Generate CalVer"
        uses: actions/github-script@v6
        id: calver
        with:
          result-encoding: string
          script: |
            const genCalVer = require('./.github/workflow-scripts/calver.js');
            const version = await genCalVer(github, context);
            return version;
      - uses: release-drafter/release-drafter@v5
        env:
          GITHUB_TOKEN: ${{ secrets.PAT_TOKEN }}
        with:
          prerelease: ${{ github.event_name != 'pull_request' }}
          publish: false
          version: "${{ steps.calver.outputs.result }}"
```

Note that the `version` input is provided to the release-drafter script. This overrides release drafter's internal version calculations, setting it to the output result of our script.
