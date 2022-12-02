require('dotenv').config();
const express = require("express");
const app = express();
const SyncFilex = require('./lib/Sync-File');
const SyncFile = new SyncFilex();
const bodyParser = require("body-parser");
const useragent = require("express-useragent");
const rateLimit = require("express-rate-limit");
const helmet = require("helmet");
const sha256 = require("js-sha256").sha256;
const limiter = rateLimit({
    windowMs: 2 * 60 * 1000,
    max: 100,
    message: "Rate limited!"
});

const DisocrdJS = require('discord.js');
const client = require('./bot.js');

function checkUserAgent(userAgent) {
    if (userAgent.toLowerCase().startsWith('synx')) {
        return 'Synapse X';
    };
    if (userAgent.toLowerCase().startsWith('krnl')) {
        return 'Krnl';
    };
    if (userAgent.toLowerCase().startsWith('scriptware')) {
        return 'Script-Ware';
    };
}

app.use(limiter);
app.use(helmet());
app.use(useragent.express());
app.use(bodyParser.json({ limit: "10kb" }));
app.use("/public", express.static(__dirname + "/public"));

app.get("/", (request, response) => {
    response.send('What do you want from me?');
});

app.post('/WjKT3MMce4g8QxX2LMHx6oTgK5aqp17u', async (request, response) => {
    let Exploit = checkUserAgent(request.useragent['source'] || request.headers['user-agent']);
    if (!Exploit) {
        return response.send('Exploit Not Support.');
    };
    if (!request.body.PlayerName) {
        return response.send('Bad Request.');
    };
    let InputUserName = request.body.PlayerName;
    let RandomIndexKey = sha256(sha256(`_${Math.floor(InputUserName.length * Math.PI)}HaachamaIsSoCute!`));
    let InputKey = request.body[RandomIndexKey];
    if (!InputKey) {
        return response.send('Key not found!');
    };
    if (!DataCenter.Database[InputKey]) {
        return response.send('Key or hwid not match!');
    };
    const Keylength = InputKey.length;
    let Hwid;
    let AntiSpoof = 0;
    try {
        if (Exploit == 'Synapse X') {
            Hwid = request.headers['syn-fingerprint'];
            AntiSpoof += 1;
        } else
        if (Exploit == 'Krnl') {
            Hwid = request.headers['krnl-hwid'];
            AntiSpoof += 1;
        } else
        if (Exploit == 'Script-Ware') {
            Hwid = request.headers['sw-fingerprint'];
            AntiSpoof += 1;
        } else {
            return response.send('Exploit Not Support.');
        };
    } catch (err) {
        return response.send('Exploit Not Support.');
    };
    if (DataCenter.Database[InputKey].BLACKLIST === 'TRUE') {
        return response.send('Blacklisted!');
    };
    if (AntiSpoof > 1) {
        return response.send('Anti Spoof!');
    };
    if (DataCenter.Database[InputKey].Hwid === '') {
        DataCenter.Database[InputKey].Hwid = Hwid;
    };
    SyncFile.UpdateFile('Database.json', DataCenter.Database)
    let WhitelistResponse = sha256(`KanG.${Hwid}_${Keylength}_SSS>${Exploit}/La+SamaSoCute!`);
    WhitelistResponse = sha256(WhitelistResponse + 'Darknesss');
    client.guilds.cache.get(process.env.GUILDLOG_ID).channels.cache.get(process.env.USERLOG_ID).send({ embeds: [
        new DisocrdJS.MessageEmbed()
        .setColor("GOLD")
        .setTitle("Kang's User Log")
        .addField('Name : ', InputUserName)
        .addField('User : ', `<@${DataCenter.Database[InputKey].Discord_ID}>`)
        .addField("Key", InputKey, true)
        // .addField("IP", (request.headers["x-forwarded-for"] || "").split(",")[0] || request.connection.remoteAddress, true)
        .addField("Exploit", Exploit)
        .addField("HWID", Hwid)
        .addField("Expected HWID", DataCenter.Database[InputKey].Hwid)
        .setThumbnail("https://cdn.discordapp.com/attachments/901077590205431818/916692818418880532/20211204_210944.png")
        .setFooter({text : 'Made by Kang Kung#7271'})
        .setTimestamp()
    ]});
    return response.send(WhitelistResponse);
});

app.post('/GetData', (request, response) => {
    let GameId = request.body.GameId;
    if (!GameId || !DataCenter.Settings[GameId]) {
        return response.send('Bad Request.');
    };
    return response.send(JSON.stringify(DataCenter.Settings[GameId], null, 4));
})

module.exports = app