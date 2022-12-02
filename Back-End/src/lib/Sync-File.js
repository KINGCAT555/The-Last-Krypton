const fs = require('fs');
const path = require('path');
const pathOfDatacenter = path.join(__dirname, '..', '..', 'DataCenter');
var DataCenter = {};
function Reload() {
    let File = fs.readdirSync(pathOfDatacenter);
    for (const Key in File) {
        if (Object.hasOwnProperty.call(File, Key)) {
            const Value = File[Key];
            DataCenter[Value] = JSON.parse(fs.readFileSync(path.join(pathOfDatacenter, Value), "utf-8"))
        }
    };
};

Reload()

class SyncFile {
    UpdateFile(FileName, Data) {
        if (fs.existsSync(path.join(__dirname, '..', '..', 'DataCenter', FileName))) {
            fs.writeFileSync(path.join(pathOfDatacenter, FileName), JSON.stringify(Data, null, 4), (err) => {
                throw new Error('can\'t upload file!');
            })
        } else {
            throw new Error('File not found!')
        };
    };
    get () {
        let X = {};
        let File = fs.readdirSync(pathOfDatacenter);
        for (const Key in File) {
            if (Object.hasOwnProperty.call(File, Key)) {
                const Value = File[Key];
                X[Value.split(".")[0]] = JSON.parse(fs.readFileSync(path.join(pathOfDatacenter, Value), "utf-8"))
            };
        };
        return X
    };
}

module.exports = SyncFile