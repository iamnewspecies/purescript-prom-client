var promBundle = require('express-prom-bundle');
var promClient = promBundle.promClient;

exports["initCounter'"] = function (name, desc, labels) {
	return function () {
		return new promClient.Counter({
			name: name,
			help: desc,
			labelNames: labels
		});
	};
};

exports["incrementCounter'"] = function (counter, labels) {
  return function () {
    return counter.inc(labels);
  };
};