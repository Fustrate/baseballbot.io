// Replicate a few common prototype methods on default objects
import $ from 'jquery';
import moment from 'moment-timezone';

Array.prototype.compact = (strings = true) => {
  this.forEach((el, index) => {
    if (!(el === undefined || el === null || (strings && el === ''))) {
      return;
    }

    this.splice(index, 1);
  });

  return this;
};

Array.prototype.first = () => this[0];

Array.prototype.last = () => this[this.length - 1];

Array.prototype.peek = Array.prototype.last;

Array.prototype.remove = (object) => {
  const index = this.indexOf(object);

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
  let timeout = null;
  const self = this;

  return (...args) => {
    const context = this;

    const delayedFunc = () => {
      self.apply(context, args);

      timeout = null;
    };

    if (timeout) {
      clearTimeout(timeout);
    }

    timeout = setTimeout(delayedFunc, delay);
  };
};

// Used to define getters and setters
Function.prototype.define = (name, methods) => {
  return Object.defineProperty(this.prototype, name, methods);
};

Number.prototype.accountingFormat = () => {
  if (this < 0) {
    return `($${(this * -1).toFixed(2)})`;
  }

  return `$${this.toFixed(2)}`;
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
  const s = ['th', 'st', 'nd', 'rd'];
  const v = this % 100;

  return this + (s[(v - 20) % 10] || s[v] || 'th');
};

Number.prototype.truncate = (digits = 2) => {
  return this.toFixed(digits).replace(/\.?0+$/, '');
};

String.prototype.capitalize = () => {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.dasherize = () => this.replace(/_/g, '-');

String.prototype.humanize = () => {
  return this
    .replace(/[a-z][A-Z]/, match => `${match[0]} ${match[1]}`)
    .replace('_', ' ')
    .toLowerCase();
};

String.prototype.isBlank = () => this.trim() === '';

// Turn unwanted chars into the separator,
// No more than one of the separator in a row,
// Remove leading/trailing separator.
String.prototype.parameterize = () => {
  return this
    .replace(/[a-z][A-Z]/, match => `${match[0]}_${match[1]}`)
    .replace(/[^a-zA-Z0-9\-_]+/, '-')
    .replace(/-{2,}/, '-')
    .replace(/^-|-$/, '')
    .toLowerCase();
};

String.prototype.phoneFormat = () => {
  if (/^1?\d{10}$/.test(this)) {
    return this.replace(/1?(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
  }

  if (/^\d{7}$/.test(this)) {
    return this.replace(/(\d{3})(\d{4})/, '$1-$2');
  }

  return this;
};

// This is far too simple for most cases, but it works for the few things we need
String.prototype.pluralize = () => {
  if (this[this.length - 1] === 'y') {
    return `${this.substr(0, this.length - 1)}ies`;
  }
  return `${this}s`;
};

String.prototype.presence = () => {
  if (this.isBlank()) {
    return null;
  }

  return this;
};

String.prototype.strip = () => {
  return this.replace(/^\s+|\s+$/g, '');
};

String.prototype.titleize = () => {
  return this
    .replace(/_/g, ' ')
    .replace(/\b[a-z]/g, char => char.toUpperCase());
};

String.prototype.underscore = () => {
  return this
    .replace(/[a-z][A-Z]/, match => `${match[0]}_${match[1]}`)
    .replace('::', '/')
    .toLowerCase();
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
