// Replicate a few common prototype methods on default objects
import $ from 'jquery'
import moment from 'moment'

Array.prototype.compact = function(strings = true) {
  this.forEach((el, index) => {
    if (!(el === void 0 || el === null || (strings && el === ''))) {
      return;
    }
    return this.splice(index, 1);
  });
  return this;
};

Array.prototype.first = function() {
  return this[0];
};

Array.prototype.last = function() {
  return this[this.length - 1];
};

Array.prototype.peek = Array.prototype.last;

Array.prototype.remove = function(object) {
  var index;
  index = this.indexOf(object);
  if (index !== -1) {
    return this.splice(index, 1);
  }
};

Array.prototype.toSentence = function() {
  switch (this.length) {
    case 0:
      return '';
    case 1:
      return this[0];
    case 2:
      return `${this[0]} and ${this[1]}`;
    default:
      return `${this.slice(0, -1).join(', ')}, and ${this[this.length - 1]}`;
  }
};

Function.prototype.debounce = function(delay = 250) {
  var timeout = null;
  var self = this;

  return function(...args) {
    var context = this;

    var delayedFunc = function() {
      self.apply(context, args);
      return timeout = null;
    };
    if (timeout) {
      clearTimeout(timeout);
    }
    return timeout = setTimeout(delayedFunc, delay);
  };
};

// Used to define getters and setters
Function.prototype.define = function(name, methods) {
  return Object.defineProperty(this.prototype, name, methods);
};

Number.prototype.accountingFormat = function() {
  if (this < 0) {
    return `($${(this * -1).toFixed(2)})`;
  } else {
    return `$${this.toFixed(2)}`;
  }
};

Number.prototype.bytesToString = function() {
  if (this < 1000) {
    return `${this} B`;
  }
  if (this < 1000000) {
    return `${(this / 1000).truncate()} kB`;
  }
  if (this < 1000000000) {
    return `${(this / 1000000).truncate()} MB`;
  }
  return `${(this / 1000000000).truncate()} GB`;
};

Number.prototype.ordinalize = function() {
  var s, v;
  s = ['th', 'st', 'nd', 'rd'];
  v = this % 100;
  return this + (s[(v - 20) % 10] || s[v] || 'th');
};

Number.prototype.truncate = function(digits = 2) {
  return this.toFixed(digits).replace(/\.?0+$/, '');
};

String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.dasherize = function() {
  return this.replace(/_/g, '-');
};

String.prototype.humanize = function() {
  return this.replace(/[a-z][A-Z]/, function(match) {
    return `${match[0]} ${match[1]}`;
  }).replace('_', ' ').toLowerCase();
};

String.prototype.isBlank = function() {
  return this.trim() === '';
};

String.prototype.parameterize = function() {
  return this.replace(/[a-z][A-Z]/, function(match) {
    return `${match[0]}_${match[1]}`;
  }).replace(/[^a-zA-Z0-9\-_]+/, '-').replace(/\-{2,}/, '-').replace(/^\-|\-$/, '').toLowerCase(); // Turn unwanted chars into the separator // No more than one of the separator in a row. // Remove leading/trailing separator.
};

String.prototype.phoneFormat = function() {
  if (/^1?\d{10}$/.test(this)) {
    return this.replace(/1?(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
  } else if (/^\d{7}$/.test(this)) {
    return this.replace(/(\d{3})(\d{4})/, '$1-$2');
  } else {
    return this;
  }
};

// This is far too simple for most cases, but it works for the few things we need
String.prototype.pluralize = function() {
  if (this[this.length - 1] === 'y') {
    return this.substr(0, this.length - 1) + 'ies';
  }
  return this + 's';
};

String.prototype.presence = function() {
  if (this.isBlank()) {
    return null;
  } else {
    return this;
  }
};

String.prototype.strip = function() {
  return this.replace(/^\s+|\s+$/g, '');
};

String.prototype.titleize = function() {
  return this.replace(/_/g, ' ').replace(/\b[a-z]/g, function(char) {
    return char.toUpperCase();
  });
};

String.prototype.underscore = function() {
  return this.replace(/[a-z][A-Z]/, function(match) {
    return `${match[0]}_${match[1]}`;
  }).replace('::', '/').toLowerCase();
};

$.fn.outerHTML = function() {
  if (!this.length) {
    return '';
  }
  if (this[0].outerHTML) {
    return this[0].outerHTML;
  }
  return $('<div>').append(this[0].clone()).remove().html();
};

moment.fn.toHumanDate = function(time = false) {
  var year;
  year = this.year() !== moment().year() ? '/YY' : '';
  return this.format(`M/D${year}${(time ? ' h:mm A' : '')}`);
};
