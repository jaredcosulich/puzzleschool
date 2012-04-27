bcrypt = require('bcrypt')
crypto = require('crypto')
line = require('line')

db = require('../lib/db')
router = require('../lib/router')

router.add
    '/api/login': ->
        console.log("HI")
        @sendText("HI")