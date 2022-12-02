const axios = require('axios');
const tls = require('tls');
tls.DEFAULT_MIN_VERSION = 'TLSv1.3';
class TrueWallet {
    constructor(phoneNumber) {
        if (phoneNumber == undefined || phoneNumber.length != 10) {
            throw new Error('Please provide a phone number 10 digits');
        }

        this.phoneNumber = phoneNumber.toString();
    };

    async redeem(Code) {
        try {
            let response = await axios({
                method: 'post',
                url: 'https://gift.truemoney.com/campaign/vouchers/' + Code + '/redeem',
                headers: {
                    accept: 'application/json',
                    origin: 'https://gift.truemoney.com',
                    referer: 'https://gift.truemoney.com/campaign/?v=' + Code,
                },
                data : {
                    mobile : this.phoneNumber,
                    voucher_hash : Code
                }
            })
            return response.data;
        } catch (err) {
            // throw err.response;
        }    

    }
}

module.exports = TrueWallet;