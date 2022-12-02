const { execSync } = require('child_process');
const Commands = [
    'git pull',
    'git status',
    'git submodule sync',
    'git submodule update',
    'git submodule status',
    'npm install',
    'pm2 restart "Krypton Hosting"'
]

var currentdate = new Date(); 
var datetime = "Last Sync: " + currentdate.getDate() + "/"
                + (currentdate.getMonth()+1)  + "/" 
                + currentdate.getFullYear() + " @ "  
                + currentdate.getHours() + ":"  
                + currentdate.getMinutes() + ":" 
                + currentdate.getSeconds();

console.log("----------------------------");
console.log(`Updating Date : ${datetime}`);

Commands.forEach(element => {
    console.log(execSync(element).toString("utf-8"))
});

console.log("----------------------------");
