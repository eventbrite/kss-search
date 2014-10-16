var DEFAULT_INDEX_FILE, KSSIndex, Q, fs, kss, lunr;

fs = require('fs');

Q = require('q');

lunr = require('lunr');

kss = require('kss');

DEFAULT_INDEX_FILE = "kss-index.json";

KSSIndex = (function() {
  KSSIndex.prototype.DEFAULT_INDEX_FILE = DEFAULT_INDEX_FILE;

  function KSSIndex() {
    this.index = lunr(function() {
      this.ref('section');
      this.field('header', {
        boost: 10
      });
      this.field('section', {
        boost: 20
      });
      return this.field('description');
    });
  }

  KSSIndex.prototype.indexSection = function(section) {
    this.index.add({
      section: section.reference(),
      header: section.header(),
      desription: section.description()
    });
    return console.log("indexed " + (section.reference()));
  };

  KSSIndex.prototype.indexFiles = function(path) {
    console.log(path);
    return Q.nfcall(kss.traverse, path, {}).then((function(_this) {
      return function(response) {
        return response.data.sections.forEach(function(section) {
          return _this.indexSection(section);
        });
      };
    })(this));
  };

  KSSIndex.prototype.search = function(query) {
    return this.index.search(query);
  };

  KSSIndex.prototype.save = function(destination) {
    destination = destination || DEFAULT_INDEX_FILE;
    return Q.nfcall(fs.writeFile, destination, JSON.stringify(this.index.toJSON()));
  };

  KSSIndex.load = function(data) {
    var index;
    index = new this();
    index.index = lunr.Index.load(JSON.parse(data));
    return index;
  };

  KSSIndex.loadFile = function(source) {
    var data;
    source = source || DEFAULT_INDEX_FILE;
    data = fs.readFileSync(source);
    return this.load(data);
  };

  return KSSIndex;

})();

module.exports = KSSIndex;
