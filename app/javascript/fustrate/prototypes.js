// Replicate a few common prototype methods on default objects
import $ from 'jquery'
import moment from 'moment'

Array.prototype.compact = (strings = true) => {
  this.forEach((el, index) => {
    if (!(el === void 0 || el === null || (strings && el === ''))) {
      return;
    }

    return this.splice(index, 1);
  });

  return this;
};

Array.prototype.first = () => {
  return this[0];
};

Array.prototype.last = () => {
  return this[this.length - 1];
};

Array.prototype.peek = Array.prototype.last;

Array.prototype.remove = object => {
  var index = this.indexOf(object);

  if (index !== -1) {
    this.splice(index, 1);
  }
};

Array.prototype.toSentence = () => {
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

Function.prototype.debounce = (delay = 250) => {
  var timeout = null;
  var self = this;

  return (...args) => {
    var context = this;

    var delayedFunc = () => {
      self.apply(context, args);

      timeout = null;
    };

    if (timeout) {
      clearTimeout(timeout);
    }

    return timeout = setTimeout(delayedFunc, delay);
  };
};

// Used to define getters and setters
Function.prototype.define = (name, methods) => {
  return Object.defineProperty(this.prototype, name, methods);
};

Number.prototype.accountingFormat = () => {
  if (this < 0) {
    return `($${(this * -1).toFixed(2)})`;
  } else {
    return `$${this.toFixed(2)}`;
  }
};

Number.prototype.bytesToString = () => {
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

Number.prototype.ordinalize = () => {
  var s, v;
  s = ['th', 'st', 'nd', 'rd'];
  v = this % 100;
  return this + (s[(v - 20) % 10] || s[v] || 'th');
};

Number.prototype.truncate = (digits = 2) => {
  return this.toFixed(digits).replace(/\.?0+$/, '');
};

String.prototype.capitalize = () => {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.dasherize = () => {
  return this.replace(/_/g, '-');
};

String.prototype.humanize = () => {
  return this.replace(/[a-z][A-Z]/, (match) => {
    return `${match[0]} ${match[1]}`;
  }).replace('_', ' ').toLowerCase();
};

String.prototype.isBlank = () => {
  return this.trim() === '';
};

String.prototype.parameterize = () => {
  return this.replace(/[a-z][A-Z]/, (match) => {
    return `${match[0]}_${match[1]}`;
  }).replace(/[^a-zA-Z0-9\-_]+/, '-').replace(/\-{2,}/, '-').replace(/^\-|\-$/, '').toLowerCase(); // Turn unwanted chars into the separator // No more than one of the separator in a row. // Remove leading/trailing separator.
};

String.prototype.phoneFormat = () => {
  if (/^1?\d{10}$/.test(this)) {
    return this.replace(/1?(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
  } else if (/^\d{7}$/.test(this)) {
    return this.replace(/(\d{3})(\d{4})/, '$1-$2');
  } else {
    return this;
  }
};

// This is far too simple for most cases, but it works for the few things we need
String.prototype.pluralize = () => {
  if (this[this.length - 1] === 'y') {
    return this.substr(0, this.length - 1) + 'ies';
  }
  return this + 's';
};

String.prototype.presence = () => {
  if (this.isBlank()) {
    return null;
  } else {
    return this;
  }
};

String.prototype.strip = () => {
  return this.replace(/^\s+|\s+$/g, '');
};

String.prototype.titleize = () => {
  return this.replace(/_/g, ' ').replace(/\b[a-z]/g, char => {
    return char.toUpperCase();
  });
};

String.prototype.underscore = () => {
  return this.replace(/[a-z][A-Z]/, match => {
    return `${match[0]}_${match[1]}`;
  }).replace('::', '/').toLowerCase();
};

$.fn.outerHTML = () => {
  if (!this.length) {
    return '';
  }

  if (this[0].outerHTML) {
    return this[0].outerHTML;
  }

  return $('<div>').append(this[0].clone()).remove().html();
};

moment.fn.toHumanDate = (time = false) => {
  const year = this.year() !== moment().year() ? '/YY' : '';

  return this.format(`M/D${year}${(time ? ' h:mm A' : '')}`);
};
