const { exec } = require('child_process');
const fs = require('fs');

const skipVersions = /http|rc|beta|pre/;

const { dependencies, devDependencies } = JSON.parse(fs.readFileSync('./package.json').toString());

const packages = Object.keys(dependencies).filter((name) => !dependencies[name].match(skipVersions));

console.log(`yarn add ${packages.join(' ')}`);
exec(`yarn add ${packages.join(' ')}`);

const devPackages = Object.keys(devDependencies).filter((name) => !devDependencies[name].match(skipVersions));

console.log(`yarn add -D ${devPackages.join(' ')}`);
exec(`yarn add -D ${devPackages.join(' ')}`);
