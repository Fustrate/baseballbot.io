const { exec } = require('child_process');

const { dependencies, devDependencies } = require('../../package.json');

const skipVersions = /http|rc|beta|pre/;

const packages = Object.keys(dependencies).filter((name) => !skipVersions.test(dependencies[name]));
const devPackages = Object.keys(devDependencies).filter((name) => !skipVersions.test(devDependencies[name]));

exec(`yarn add ${packages.join(' ')} && yarn add -D ${devPackages.join(' ')}`);
