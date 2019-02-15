import Rails from 'rails-ujs';
import moment from 'moment-timezone';
import $ from 'jquery';

import Component from './component';

require('./prototypes');

const entityMap = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;',
};

class Fustrate {
  static start() {
    Fustrate.class = this;
    Fustrate.instance = new this();

    document.addEventListener('DOMContentLoaded', () => {
      this.initialize();
    });
  }

  constructor() {
    moment.updateLocale('en', {
      longDateFormat: {
        LTS: 'h:mm:ss A',
        LT: 'h:mm A',
        L: 'M/D/YY',
        LL: 'MMMM D, YYYY',
        LLL: 'MMMM D, YYYY h:mm A',
        LLLL: 'dddd, MMMM D, YYYY h:mm A',
      },
      calendar: {
        lastDay: '[Yesterday at] LT',
        sameDay: '[Today at] LT',
        nextDay: '[Tomorrow at] LT',
        lastWeek: 'dddd [at] LT',
        nextWeek: '[next] dddd [at] LT',
        sameElse: 'L',
      },
    });
  }

  static initialize() {
    Rails.start();

    Component.initialize();

    // document.querySelectorAll('[data-js-class]').forEach((element) => {
    //   klass = Fustrate.stringToClass(element.dataset.jsClass);
    //   element.object = new klass($(element));
    // });

    $.ajaxSetup({
      cache: false,
      beforeSend: Rails.CSRFProtection,
    });

    $('table').wrap('<div class="responsive-table"></div>');
  }

  static stringToClass(name) {
    return Fustrate.arrayToClass(window, name.split('.'));
  }

  static arrayToClass(root, segments) {
    if (segments.length === 1) {
      return root[segments[0]];
    }

    return Fustrate.arrayToClass(root[segments[0]], segments.slice(1));
  }

  static linkTo(text, href, options = {}) {
    const path = href.path ? href.path() : href;

    return $('<a>').prop('href', path).html(text).prop(options)
      .outerHTML();
  }

  static ajaxUpload(url, data) {
    const formData = new FormData();

    Object.keys(data).forEach((key) => {
      formData.append(key, data[key]);
    });

    return $.ajax({
      url,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      dataType: 'script',
      beforeSend: Rails.CSRFProtection,
    });
  }

  static getCurrentPageJson() {
    const pathname = window.location.pathname.replace(/\/+$/, '');

    return $.get(`${pathname}.json${window.location.search}`);
  }

  static label(text, type) {
    const classes = ['label', text.replace(/\s+/g, '-'), type]
      .compact()
      .join(' ')
      .toLowerCase()
      .dasherize();

    return $('<span>').text(text).prop('class', classes);
  }

  static icon(types, style = 'regular') {
    const classes = types.split(' ')
      .map(thing => `fa-${thing}`)
      .join(' ');

    return `<i class="fa${style[0]} ${classes}"></i>`;
  }

  static escapeHtml(string) {
    if (string === null || string === undefined) {
      return '';
    }

    return String(string).replace(/[&<>"'`=/]/g, entity => entityMap[entity]);
  }

  static multilineEscapeHtml(string) {
    if (string === null || string === undefined) {
      return '';
    }

    return String(string)
      .split(/\r?\n/)
      .map(line => Fustrate.escapeHtml(line))
      .join('<br />');
  }

  static redirectTo(href) {
    const path = href.path ? href.path() : href;

    window.setTimeout(() => {
      window.location.href = path;
    }, 750);
  }
}

window.Fustrate = Fustrate;
window.$ = $;

export default Fustrate;
