const fs = require('fs');
const path = require('path');

global.DataCenter = {};
const pathOfDatacenter = path.join(__dirname, '..', 'DataCenter');
let File = fs.readdirSync(pathOfDatacenter);
for (const Key in File) {
    if (Object.hasOwnProperty.call(File, Key)) {
        const Value = File[Key];
        DataCenter[Value.split(".")[0]] = JSON.parse(fs.readFileSync(path.join(pathOfDatacenter, Value), "utf-8"))
    };
};

const bot = require('./bot');
const server = require('./server');

server.post('/DeployServer_____Eww', (request, response, next) => {
    let Heander = request.headers;
    if (!Heander || !Heander['user-agent'] || !Heander['x-github-hook-id'] || !Heander['user-agent'].startsWith('GitHub-Hookshot')) {
        return;
    };
    require('./DeployServer');
    return response.send("Succeed!");
})

bot.login(process.env.BOT_TOKEN);

server.listen(process.env.PORT, () => {
    console.log(`Server is listening on port ${process.env.PORT}`)
})
