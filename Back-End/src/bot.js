require('dotenv').config();
const { Client, Intents, Guild, } = require('discord.js');
const DisocrdJS =require('discord.js');
const client = new Client({ intents: [Intents.FLAGS.GUILDS, Intents.FLAGS.GUILD_MESSAGES] });
const COOLDOWN = new Set();
const TrueWalletApi = require('./lib/TrueWallet.js');
const TrueWallet = new TrueWalletApi(process.env.PHONE_NUMBER);
const SyncFilex = require('./lib/Sync-File');
const SyncFile = new SyncFilex();
const converter = {
    FormDatabase : (discordId) => {
        for (const index in DataCenter.Database) {
            if (DataCenter.Database.hasOwnProperty(index)) {
                let value = DataCenter.Database[index]
                if (value.Discord_ID === discordId) {
                    return index
                }       
            }
        }
        return false
    },
    FormProductKey : (discordId) => {
        for (const index in DataCenter.ProductKey) {
            if (DataCenter.ProductKey.hasOwnProperty(index)) {
                let value = DataCenter.ProductKey[index]
                if (value.Discord_ID === discordId) {
                    return index
                }       
            }
        }
        return false
    }
};

const random = {
    createWhitelist : (length) => {
        var result = "Key_";
        var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var charactersLength = characters.length;
        function main() {
            for (var i = 0; i < length; i++) {
                result += characters.charAt(Math.floor(Math.random() * charactersLength));
            };
            if (DataCenter.Database[result]) return main();
        };
        main();
        return result;
    },
    createProductKey : (length) => {
        var result = "";
        var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var charactersLength = characters.length;
    
        function main() {
            for (var i = 0; i < length; i++) {
                if (result.length !== 0 && Math.floor(result.length / 5) === (result.length / 5)) {
                    result += '-'
                }
                result += characters.charAt(Math.floor(Math.random() * charactersLength));
            };
            if (DataCenter.ProductKey[result]) return main();
        }
        main();
        return result;
    }
};

const Commands = [];

const Bot_Data = {
    Token : process.env['BOT_TOKEN'],
    GuildID : process.env['GUILD_ID'],
    GuildLogID: process.env['GUILDLOG_ID'],
    BuyerID : process.env['Buyer_ID'],
    PhoneNumber : process.env['PHONE_NUMBER'],
    Script_Price : parseInt(process.env['SCRIPT_PRICE']),
    Administrator_Id : process.env['ADMINISTRATOR_ID'],
    UpdatePaid_Channal_ID : process.env['UPDATE_CHANNALID_PAID'],
    UpdateFree_Channal_ID : process.env['UPDATE_CHANNALID_FREE'],
    UserLog_ID : process.env['USERLOG_ID'],
    Script : 'loadstring(game:HttpGet("https://raw.githubusercontent.com/KangKung02/H2O/main/main.lua"))();'
};
 
function SendEmbed(color, title, description) {
    return new DisocrdJS.MessageEmbed()
    .setColor(color)
    .setTitle(title)
    .setDescription(description)
    .setAuthor({name : 'H2O\'s Manager', iconURL : 'https://cdn.discordapp.com/attachments/901077590205431818/916692818418880532/20211204_210944.png', url : 'https://bit.ly/31ESQv1'})
    .setThumbnail('https://cdn.discordapp.com/attachments/901077590205431818/916692818418880532/20211204_210944.png')
    .setFooter({text : 'Made by Kang Kung#7271'})
    .setTimestamp()
}

function fortable(table, func) {
    for (var p in table) {
        if (table.hasOwnProperty(p)) {
            func(p, table[p]);
        };
    };
};

function addCommand(name, desc, option, func) {
    Commands[Object.keys(Commands).length + 1] = {
        'Name': name,
        'Description': desc,
        'Option': option,
        'Function': func,
    };
}

addCommand('ping', 'idk', [
    {
        name: 'num1',
        description: 'Input Your Number',
        required: true,
        type: DisocrdJS.Constants.ApplicationCommandOptionTypes.NUMBER
    }
], (interaction) => {
    interaction.reply('Pong!')
    const user = client.users.cache.get(interaction.member.user.id);
    user.send('IDK LMAO')
});

addCommand('redeem', 'redeem your product key.', [{
    name: 'key',
    description: 'Input your key.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}], (interaction) => {
    let Key = interaction.options.getString('key');
    let DisocrdId = interaction.member.id
    if (DataCenter.Database[converter.FormDatabase(DisocrdId)]) {
        return interaction.reply({
            content: 'Already a buyer!',
            ephemeral: true
        })
    };
    let ProtectBruteForce = {}
    if (ProtectBruteForce[DisocrdId] && ProtectBruteForce[DisocrdId] >= 5) {
        setTimeout(() => {
            ProtectBruteForce[DisocrdId] = 0
        }, 1800000);
        return interaction.reply({
            embeds: [SendEmbed('RED', 'Error!', 'you try redeem too much\n pls try again in next 30m.')],
            ephemeral: true
        })
    };
    if (typeof ProtectBruteForce[DisocrdId] === 'number') {
        ProtectBruteForce[DisocrdId] += 1
    } else {
        ProtectBruteForce[DisocrdId] = 1
    };

    if (!DataCenter.ProductKey[Key] || DataCenter.ProductKey[Key].Used === 'TRUE') {
        return interaction.reply({
            embeds: [SendEmbed('RED', 'Error!', 'This key is either invalid or has been already redeemed.')],
            ephemeral: true
        })
    };
    let CreatedKey = random.createWhitelist(29);
    DataCenter.ProductKey[Key] = {
        "Discord_ID": DisocrdId,
        "Login_Key": CreatedKey,
        "Used": "TRUE"
    };
    DataCenter.Database[CreatedKey] = {
        "Discord_ID" : DisocrdId,
        "Hwid" : "",
        "RESETHWID" : "READY",
        "BLACKLIST" : "FALSE"
    };
    SyncFile.UpdateFile('Database.json', DataCenter.Database);
    SyncFile.UpdateFile('ProductKey.json', DataCenter.ProductKey);
    interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', 'You have been whitelisted, enjoy!')] , ephemeral: true });
});

addCommand('buy', 'buy script with ???', [{
    name: 'url',
    description: 'Input your url.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}], (interaction) => {
    let Url = interaction.options.getString('url');
    let Code = Url.split("=")[1];
    let DisocrdId = interaction.member.id;
    if (Bot_Data.PhoneNumber.length !== 10) {
        return interaction.reply({
            embeds: [SendEmbed('RED', 'Error!', 'Owner\'s number phone is invalid!')],
            ephemeral: true
        })
    };
    if (!Url.startsWith('https://gift.truemoney.com/campaign/?v=' || Code.length < 18 - 1)) {
        return interaction.reply({
            embeds: [SendEmbed('RED', 'Error!', 'The type attached link is invalid.')],
            ephemeral: true
        })
    };

    let ProtectBruteForce = {}
    if (ProtectBruteForce[DisocrdId] && ProtectBruteForce[DisocrdId] >= 10) {
        setTimeout(() => {
            ProtectBruteForce[DisocrdId] = 0
        }, 1800000);
        return interaction.reply({
            embeds: [SendEmbed('RED', 'Error!', 'you try redeem too much\n pls try again in next 30m.')],
            ephemeral: true
        })
    };
    if (typeof ProtectBruteForce[DisocrdId] === 'number') {
        ProtectBruteForce[DisocrdId] += 1
    } else {
        ProtectBruteForce[DisocrdId] = 1
    };


    try {
        TrueWallet.redeem(Code).then((x) => {
            if (!x) return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'The attached link is invalid.')], ephemeral: true });
            let Amount = parseInt(x.data.my_ticket.amount_baht)
            if (Amount < Bot_Data.Script_Price - 1) return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', 'เหลี่ยมเฉย บิดดีกว่าแง้นๆ')] , ephemeral: true});
            let CreatedKey = random.createWhitelist(29);
            let NewKey = random.createProductKey(29);
            DataCenter.ProductKey[NewKey] = {
                "Discord_ID": DisocrdId,
                "Login_Key": CreatedKey,
                "Used": "TRUE"
            };
            DataCenter.Database[CreatedKey] = {
                "Discord_ID" : DisocrdId,
                "Hwid" : "",
                "RESETHWID" : "READY",
                "BLACKLIST" : "FALSE"
            };
            SyncFile.UpdateFile('Database.json', DataCenter.Database);
            SyncFile.UpdateFile('ProductKey.json', DataCenter.ProductKey);
            interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', 'You have been whitelisted, enjoy!')] , ephemeral: true });
            const user = client.users.cache.get(interaction.member.user.id);
            return user.send({ embeds: [SendEmbed('BLUE', 'Succeed!', 'Your Product-Key is : ' + NewKey)] })
        })
    } catch (err) {
        if (err.status === 400 || err.status === 404) return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'The attached link is invalid!')] });
        console.log(err);
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'Detected some error please call dev!')] });
    };
});

addCommand('resethwid', 'reset you\'re hwid can use every 24h.', [], (interaction) => {
    const DisocrdId = interaction.member.id;
    if (!DataCenter.Database[converter.FormDatabase(DisocrdId)]) return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You\'re not buyer!')], ephemeral: true });
    if (DataCenter.Database[converter.FormDatabase(DisocrdId)].RESETHWID !== "READY" && (Math.floor(new Date().getTime() * 0.001) - Number(DataCenter.Database[converter.FormDatabase(DisocrdId)].RESETHWID)) <= 86400) {
        return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', 'Now reset hwid is cooldown!')], ephemeral: true });
    };
    DataCenter.Database[converter.FormDatabase(DisocrdId)].Hwid = "";
    DataCenter.Database[converter.FormDatabase(DisocrdId)].RESETHWID = String(Math.floor(new Date().getTime() * 0.001));
    SyncFile.UpdateFile('Database.json', DataCenter.Database);

    return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', 'Reseted you\'re hwid!')] , ephemeral: true });
});
addCommand('getrole', 'get buyer role.', [], (interaction) => {
    const DisocrdId = interaction.member.id;
    if (interaction.member.roles.cache.has(Bot_Data.BuyerID)) return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'Already a buyer!')], ephemeral: true });
    if (!DataCenter.ProductKey[converter.FormProductKey(DisocrdId)]) return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You\'re not buyer!')], ephemeral: true });
    if (DataCenter.Database && DataCenter.Database[converter.FormDatabase(DisocrdId)].BLACKLIST == 'TRUE') return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You\'re Backlist.')], ephemeral: true });

    interaction.guild.roles.fetch(Bot_Data.BuyerID).then(role => {
        interaction.member.roles.add(role);
        return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', 'Just gave you buyer role!')], ephemeral: true });
    });
});

addCommand('getscript', 'gave a script hub.', [], (interaction) => {
    const DisocrdId = interaction.member.id;
    let LoginKey = 'Free-User';
    let Content = '';
    if (converter.FormDatabase(DisocrdId)) {
        LoginKey = converter.FormDatabase(DisocrdId)
    };
    Content = `getgenv().Key = "${LoginKey}";\n ${Bot_Data.Script}`
    interaction.reply({
        content : 'Sent in dm.',
        ephemeral : true
    });
    const user = client.users.cache.get(interaction.member.user.id);
    return user.send({ embeds: [SendEmbed('BLUE', 'Succeed!', '```lua\n' + Content + '```')] })
});

// admin commands

addCommand('checkkey', 'get user data for login key.', [{
    name: 'key',
    description: 'login key.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    let Key = interaction.options.getString('key');
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    if (!DataCenter.Database[Key]) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'This key is either invalid!')], ephemeral: true })
    };
    return interaction.reply({
        embeds : [SendEmbed('BLUE', 'Succeed!', JSON.stringify(DataCenter.Database[Key], null, 4))],
        ephemeral : true
    })
});

addCommand('listkey', 'get all product key.', [{
    name: 'choice',
    description: 'your choice.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.BOOLEAN
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    let Used = '';
    let Unused = '';
    fortable(DataCenter.ProductKey, (i, v) => {
        if (v.Used === 'used') {
            Used = Used + i + '\n';
        } else {
            Unused = Unused + i + '\n';
        }
    })
    if (interaction.options.getBoolean('choice')) {
        return interaction.reply({
            embeds : [SendEmbed('BLUE', 'Used Key:', Used)],
            ephemeral : true
        })
    } else {
        return interaction.reply({
            embeds : [SendEmbed('BLUE', 'Unused Key:', Unused)],
            ephemeral : true
        })
    };
});

addCommand('genkey', 'generate new key.', [{
    name: 'amount',
    description: 'amount of key.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.INTEGER
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    const Amount = interaction.options.getInteger('amount');
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true})
    };
    if (Amount > 20) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'too many amounts.')], ephemeral: true })
    };
    let AllKey = '';
    for (let i = 0; i < Amount; i++) {
        let NewKey = random.createProductKey(29);
        AllKey = AllKey + NewKey + '\n';
        DataCenter.ProductKey[NewKey] = {
            "Discord_ID": '',
            "Login_Key": '',
            "Used": "FALSE"
        };
    };
    SyncFile.UpdateFile('ProductKey.json', DataCenter.ProductKey);

    interaction.reply({
        content : 'Sent in dm.',
        ephemeral : true
    });
    const user = client.users.cache.get(interaction.member.user.id);
    return user.send({ embeds: [SendEmbed('BLUE', 'Succeed!', 'Generated new key :\n' + AllKey)] })
});

addCommand('deletekey', 'delete product key.', [{
    name: 'key',
    description: 'input keys.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    const ListKey = interaction.options.getString('key').split(",");
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    for (const Index in ListKey) {
        if (ListKey.hasOwnProperty(Index)) {
            let Value = ListKey[Index];
            Value = Value.replace(" ", "");
            if (!DataCenter.ProductKey[Value]) {
                return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', `Can't find ${Value}!`)], ephemeral: true })
            };
            delete DataCenter.ProductKey[Value]
        };
    };
    SyncFile.UpdateFile('ProductKey.json', DataCenter.ProductKey);
    return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', `Deleted ${ListKey.length} keys!`)], ephemeral: true });
});

addCommand('switchbw', 'switch between whitelist and blacklist.', [{
    name: 'id',
    description: 'input discord id.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    const UserId = interaction.options.getString('id');
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    if (!DataCenter.Database[converter.FormDatabase(UserId)]) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'This user was not a buyer!')], ephemeral: true })
    };
    const Data = DataCenter.Database[converter.FormDatabase(UserId)].BLACKLIST
    let Text;
    if (Data === 'FALSE') {
        DataCenter.Database[converter.FormDatabase(UserId)].BLACKLIST = 'TRUE';
        Text = 'Blacklisted';
    } else {        
        DataCenter.Database[converter.FormDatabase(UserId)].BLACKLIST = 'FALSE';
        Text = 'Whitelisted';
    };
    SyncFile.UpdateFile('Database.json', DataCenter.Database);
    interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', `Switch <@${UserId}> to ${Text}!`)], ephemeral: false });
    if (Text == 'Blacklisted') {
        const userDM = client.users.cache.get(UserId);
        return userDM.send({ embeds: [
            new DisocrdJS.MessageEmbed()
            .setColor('DARK_BUT_NOT_BLACK')
            .setTitle('H2O Notification')
            .setDescription(`<@${UserId}> You Got Bonk By Kang!,\nBut You Can Appeal If You Are Innocent.`)
            .setImage('https://c.tenor.com/M_UBKUF3nUEAAAAC/bonk-ina.gif')
            .setFooter({text : 'Made by Kang Kung#7271'})
            .setTimestamp()
        ]})
    }
});

addCommand('search', 'searches for a user in the database.', [{
    name: 'id',
    description: 'input discord id.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    const UserId = interaction.options.getString('id');
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    if (!DataCenter.Database[converter.FormDatabase(UserId)]) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'This user was not a buyer!')], ephemeral: true })
    };
    let Data = DataCenter.Database[converter.FormDatabase(UserId)];
    Data.Key = converter.FormDatabase(UserId);
    return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', JSON.stringify(Data, null, 4))], ephemeral: true });
})

addCommand('addgame', 'add new game.', [{
    name: 'gameid',
    description: 'input new game id.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
},
{
    name: 'gamename',
    description: 'input new game name.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}, {
    name: 'paid',
    description: 'type game.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.BOOLEAN
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    const GameId = interaction.options.getString('gameid');
    const GameName = interaction.options.getString('gamename');
    let GameType = interaction.options.getBoolean('paid');
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    if (DataCenter.Settings[GameId]) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'This game already has.')], ephemeral: true })
    };
    if (GameType) {
        GameType = 'Paid';
    } else {
        GameType = 'Free';
    };
    DataCenter.Settings[GameId] = {
        ScriptEnabled : true,
        Version : '1.0.0',
        Type : GameType,
        Name : GameName
    };
    SyncFile.UpdateFile('Settings.json', DataCenter.Settings);
    return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', `Added ${GameName} To ${GameType} Game!`)], ephemeral: true });
});

addCommand('updatescript', 'update version game.', [{
    name: 'gameid',
    description: 'input new game id.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}, {
    name: 'type',
    description: 'type version.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}, {
    name: 'content',
    description: 'update content.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}], (interaction) => {
    const DisocrdId = interaction.member.id;
    const GameId = interaction.options.getString('gameid');
    const Type = interaction.options.getString('type');
    const ContentUpdate = interaction.options.getString('content');
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    if (!DataCenter.Settings[GameId]) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'Can\'t find game.')], ephemeral: true })
    };
    let Version = DataCenter.Settings[GameId].Version.split(".");
    let Major = parseInt(Version[0]);
    let Minor = parseInt(Version[1]);
    let Patch = parseInt(Version[2]);
    if (Type.toLowerCase().startsWith('ma')) {
        Major += 1;
        Minor = 0;
        Patch = 0;
    } else 
    if (Type.toLowerCase().startsWith('mi')) {
        Minor += 1;
        Patch = 0;
    } else
    if (Type.toLowerCase().startsWith('p')) {
        Patch += 1;
    };
    Version = `${Major}.${Minor}.${Patch}`;
    DataCenter.Settings[GameId].Version = Version;
    SyncFile.UpdateFile('Settings.json', DataCenter.Settings);
    let Content = ContentUpdate.split('|');
    let RealContent = '';
    fortable(Content, (_, Value) => {
        RealContent += '\t' + Value + '\n';
    })
    if (DataCenter.Settings[GameId].Type === 'Paid') {
        interaction.guild.channels.cache.get(Bot_Data.UpdatePaid_Channal_ID).send({ embeds: [
            new DisocrdJS.MessageEmbed()
            .setColor('GOLD')
            .setTitle('Update Log')
            .setURL('https://bit.ly/31ESQv1')
            .addField('Game Name : ', DataCenter.Settings[GameId].Name, true)
            .addField('Version : ', Version, true)
            .addField("Message", RealContent)
            .setThumbnail("https://cdn.discordapp.com/attachments/901077590205431818/916692818418880532/20211204_210944.png")
            .setFooter({text : 'Made by Kang Kung#7271'})
            .setTimestamp()
        ]});
    } else {
        interaction.guild.channels.cache.get(Bot_Data.UpdateFree_Channal_ID).send({ embeds: [
            new DisocrdJS.MessageEmbed()
            .setColor('GOLD')
            .setTitle('Update Log')
            .setURL('https://bit.ly/31ESQv1')
            .addField('Game Name : ', DataCenter.Settings[GameId].Name, true)
            .addField('Version : ', Version, true)
            .addField("Message", RealContent)
            .setThumbnail("https://cdn.discordapp.com/attachments/901077590205431818/916692818418880532/20211204_210944.png")
            .setFooter({text : 'Made by Kang Kung#7271'})
            .setTimestamp()
        ]});
    };

    return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', `Updated!`)], ephemeral: true });
});

addCommand('killscript', 'Stops the script from being executed.', [{
    name: 'gameid',
    description: 'input game id.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.STRING
}, {
    name: 'choice',
    description: 'choice.',
    required: true,
    type: DisocrdJS.Constants.ApplicationCommandOptionTypes.BOOLEAN

}], (interaction) => {
    const DisocrdId = interaction.member.id;
    const GameId = interaction.options.getString('gameid');
    const Choice = interaction.options.getBoolean('choice');
    let Content;
    if (DisocrdId !== Bot_Data.Administrator_Id) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You are not authorised to run this command!')], ephemeral: true })
    };
    if (!DataCenter.Settings[GameId]) {
        return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'Can\'t find game.')], ephemeral: true })
    };
    if (Choice) {
        DataCenter.Settings[GameId].ScriptEnabled = false;
        Content = 'Disable';
    } else {
        DataCenter.Settings[GameId].ScriptEnabled = true;
        Content = 'Enabled';
    };
    SyncFile.UpdateFile('Settings.json', DataCenter.Settings);
    return interaction.reply({ embeds: [SendEmbed('BLUE', 'Succeed!', `${Content} ${GameId} Done!`)], ephemeral: true });
});


client.on('interactionCreate', async (interaction) => {
    if (!interaction.isCommand()) {
        return
    };
    const { commandName, options } = interaction;
    let DiscordId = interaction.member.id;
    fortable(Commands, (_, v) => {
        if (commandName === v.Name) {
            if (COOLDOWN.has(DiscordId)) {
                return interaction.reply({ embeds: [SendEmbed('RED', 'Error!', 'You\'re typeing too fast please\n try again in 5s!')], ephemeral: true });
            };
            COOLDOWN.add(DiscordId);
            setTimeout(() => {
                COOLDOWN.delete(DiscordId);
            }, 5000);
            try {
                v.Function(interaction)
            } catch (error) {
                console.log(`Error: ${error}`)
            }
        }
    })
})

client.on('ready', () => {
    const wait = require('util').promisify(setTimeout);
    console.log(`Logged in as ${client.user.tag}!`);
    const guild = client.guilds.cache.get(Bot_Data.GuildID) 
    let commands;
  
    if (guild) {
        commands = guild.commands
    } else {
        commands = client.application.commands
    };
    fortable(Commands, (_, v) => {
        commands.create({
            name: v.Name,
            description: v.Description,
            options: v.Option
        })
    })
    client.user.setPresence({ activities: [{ name: `อยู่ไทยแล้วไม่มีไรดี ขอกลับไป สิงคโปร์ละกัน :>`, type: `PLAYING` }] })
});



module.exports = client;