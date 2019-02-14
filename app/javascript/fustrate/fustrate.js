import Rails from 'rails-ujs';
import moment from 'moment-timezone';
import $ from 'jquery';

class Fustrate {
  static start(name) {
    this.class = window[name];
    this.instance = new this.class;
    this.instance.initialize();
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

    document.querySelectorAll('[data-js-class]').forEach(element => {
      klass = Fustrate._stringToClass(element.dataset.jsClass);
      element.object = new klass($(element));
    });

    $.ajaxSetup({
      cache: false,
      beforeSend: Rails.CSRFProtection
    });

    $('table').wrap('<div class="responsive-table"></div>');
  }

  static _stringToClass(name) {
    var segments = name.split('.');

    return Fustrate._arrayToClass(window, segments);
  }

  static _arrayToClass(root, segments) {
    if (segments.length === 1) {
      return root[segments[0]];
    }

    return Fustrate._arrayToClass(root[segments[0]], segments.slice(1));
  }

  static linkTo(text, href, options = {}) {
    var path = href.path ? href.path() : href;

    return $('<a>').prop('href', path).html(text).prop(options).outerHTML();
  }

  static ajaxUpload(url, data) {
    var formData, key, value;
    formData = new FormData;
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
      beforeSend: function(xhr) {
        return Rails.CSRFProtection(xhr);
      }
    });
  }

  static getCurrentPageJson() {
    var pathname;
    pathname = window.location.pathname.replace(/\/+$/, '');
    return $.get(`${pathname}.json${window.location.search}`);
  }

  static label(text, type) {
    var css_classes = ['label', text.replace(/\s+/g, '-'), type].compact();

    return $('<span>').text(text).prop('class', css_classes.join(' ').toLowerCase().dasherize());
  }

  static icon(types, style = 'regular') {
    var classes, type;

    classes = ((function() {
      var k, len, ref, results;
      ref = types.split(' ');
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        type = ref[k];
        results.push(`fa-${type}`);
      }
      return results;
    })()).join(' ');

    return `<i class="fa${style[0]} ${classes}"></i>`;
  }

  static escapeHtml(string) {
    if (string === null || string === void 0) {
      return '';
    }
    return String(string).replace(/[&<>"'`=\/]/g, function(s) {
      return Fustrate.entityMap[s];
    });
  }

  static multilineEscapeHtml(string) {
    if (string === null || string === void 0) {
      return '';
    }
    return String(string).split(/\r?\n/).map(function(line) {
      return Fustrate.escapeHtml(line);
    }).join('<br />');
  }

  static redirectTo(href) {
    var path;
    path = href.path ? href.path() : href;
    return window.setTimeout((function() {
      return window.location.href = path;
    }), 750);
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

export default Fustrate
