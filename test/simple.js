const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = require('chai').expect;
chai.use(chaiHttp);

const uri = process.env.URI;

const paths = [
  "/hello-world",
  "/hello-world-pretty",
  "/data-types",
  "/kitchen-sink",
  "/geoip",
  "/objects"
];

it(`receives an HTML response from /`, (done) => {
  chai.request(uri)
    .get('/')
    .end((err, res) => {
      expect(res).to.have.status(200);
      expect(res).to.be.html;
      expect(res.text).to.include('<pre>');
      done();
  });
});

paths.forEach((path) => {
  it(`receives a JSON response from ${path}`, (done) => {
    chai.request(uri)
      .get(path)
      .end((err, res) => {
        expect(res).to.have.status(200);
        expect(res).to.be.json;
        expect(res.body).to.be.an('object');
        done();
    });
  });
});
