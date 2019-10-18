if (typeof initMochaPhantomJS === 'function') {
  initMochaPhantomJS()
}

mocha.ui('bdd');

chai.should();
