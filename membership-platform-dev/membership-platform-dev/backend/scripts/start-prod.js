
const service = process.argv[2];

if (!service) {
  console.error("❌ You must specify a service. Example:");
  console.error("   yarn start:prod membership-service");
  process.exit(1);
}

const { execSync } = require("child_process");

const command = `node dist/apps/${service}/main`;

console.log(`🚀 Starting service: ${service}`);
execSync(command, { stdio: "inherit" });
