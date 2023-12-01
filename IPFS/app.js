const express = require('express');
const app = express();
const fs = require('fs');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

// Menggunakan endpoint default dari IPFS Desktop
const ipfsAPI = require('ipfs-api');
const ipfs = ipfsAPI({ host: 'localhost', port: '5001', protocol: 'http' });

app.get('/', function (req, res) {
  res.sendFile(__dirname + '/public/index.html');
});

app.post('/profile', upload.single('avatar'), function (req, res, next) {
  console.log(req.file);
  var data = Buffer.from(fs.readFileSync(req.file.path));
  ipfs.add(data, function (err, file) {
    if (err) {
      console.log(err);
      res.status(500).send('Internal server error');
      return;
    }
    console.log(file);
    res.send(file[0].hash);
  });
});

app.get('/download/:ID', function (req, res) {
  console.log(req.params.ID);
  res.redirect('https://ipfs.io/ipfs/' + req.params.ID);
});

app.listen(3000);
