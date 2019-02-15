import Rails from 'rails-ujs'
import moment from 'moment-timezone'
import $ from 'jquery'
import Component from './component'

require('./prototypes')

class Fustrate {
  static start() {
    Fustrate.class = this;
    Fustrate.instance = new Fustrate.class;

    document.addEventListener('DOMContentLoaded', () => {
      Fustrate.instance.initialize();
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
        LLLL: 'dddd, MMMM D, YYYY h:mm A'
      },
      calendar: {
        lastDay: '[Yesterday at] LT',
        sameDay: '[Today at] LT',
        nextDay: '[Tomorrow at] LT',
        lastWeek: 'dddd [at] LT',
        nextWeek: '[next] dddd [at] LT',
        sameElse: 'L'
      }
    });
  }

  initialize() {
    Rails.start();

    Component.initialize()

    for (let element of document.querySelectorAll('[data-js-class]')) {
      // klass = Fustrate._stringToClass(element.dataset.jsClass);
      // element.object = new klass($(element));
    }

    $.ajaxSetup({
      cache: false,
      beforeSend: Rails.CSRFProtection
    });

    $('table').wrap('<div class="responsive-table"></div>');
  }

  static _stringToClass(name) {
    return Fustrate._arrayToClass(window, name.split('.'));
  }

  static _arrayToClass(root, segments) {
    if (segments.length === 1) {
      return root[segments[0]];
    }

    return Fustrate._arrayToClass(root[segments[0]], segments.slice(1));
  }

  static linkTo(text, href, options = {}) {
    const path = href.path ? href.path() : href;

    return $('<a>').prop('href', path).html(text).prop(options).outerHTML();
  }

  static ajaxUpload(url, data) {
    var key, value;
    var formData = new FormData;

    for (key in data) {
      value = data[key];
      formData.append(key, value);
    }

    return $.ajax({
      url: url,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      dataType: 'script',
      beforeSend: xhr => {
        return Rails.CSRFProtection(xhr);
      }
    });
  }

  static getCurrentPageJson() {
    const pathname = window.location.pathname.replace(/\/+$/, '');

    return $.get(`${pathname}.json${window.location.search}`);
  }

  static label(text, type) {
    const css_classes = ['label', text.replace(/\s+/g, '-'), type]
      .compact()
      .join(' ')
      .toLowerCase()
      .dasherize();

    return $('<span>').text(text).prop('class', css_classes);
  }

  static icon(types, style = 'regular') {
    const classes = types.split(' ').map(thing => {
      return `fa-${thing}`
    }).join(' ')

    return `<i class="fa${style[0]} ${classes}"></i>`;
  }

  static escapeHtml(string) {
    if (string === null || string === void 0) {
      return '';
    }

    return String(string).replace(/[&<>"'`=\/]/g, entity => {
      return Fustrate.entityMap[entity];
    });
  }

  static multilineEscapeHtml(string) {
    if (string === null || string === void 0) {
      return '';
    }

    return String(string).split(/\r?\n/).map(line => {
      return Fustrate.escapeHtml(line);
    }).join('<br />');
  }

  static redirectTo(href) {
    let path = href.path ? href.path() : href;

    window.setTimeout(() => {
      return window.location.href = path;
    }, 750);
  }
}

Fustrate.entityMap = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;'
}

window.Fustrate = Fustrate
window.$ = $

export default Fustrate
