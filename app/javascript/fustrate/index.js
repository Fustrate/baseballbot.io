import moment from 'moment';
import $ from 'jquery';

import Component from './component';

require('./prototypes');

// const Rails = require('@rails/ujs');

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
  static start(instance) {
    Fustrate.instance = instance;

    document.addEventListener('DOMContentLoaded', () => {
      // Rails.start();

      this.initialize();
      instance.initialize();
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
    Component.initialize();

    $.ajaxSetup({
      cache: false,
      // beforeSend: Rails.CSRFProtection,
    });

    document.querySelectorAll('table').forEach((table) => {
      const wrapper = document.createElement('div');
      wrapper.classList.add('responsive-table');

      table.parentNode.insertBefore(wrapper, table);

      wrapper.appendChild(table);
    });
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
    const element = document.createElement('a');

    element.href = href.path ? href.path() : href;
    element.innerHTML = text;

    Object.keys(options).forEach((key) => {
      element.setAttribute(key, options[key]);
    });

    return element.outerHTML;
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
      // beforeSend: Rails.CSRFProtection,
    });
  }

  static getCurrentPageJson() {
    const pathname = window.location.pathname.replace(/\/+$/, '');

    return $.get(`${pathname}.json${window.location.search}`);
  }

  static label(text, type) {
    const classes = ['label', type, text.replace(/\s+/g, '-')]
      .compact()
      .join(' ')
      .toLowerCase()
      .dasherize()
      .split(' ');

    const span = document.createElement('span');
    span.textContent = text;
    span.classList.add(...classes);

    return span.outerHTML;
  }

  static icon(types, style = 'regular') {
    const classes = types.split(' ')
      .map(thing => `fa-${thing}`)
      .join(' ');

    return `<i class="fa${style[0]} ${classes}"></i>`;
  }

  static elementFromString(string) {
    const template = document.createElement('template');

    template.innerHTML = string.trim();

    return template.content.firstChild;
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
    window.setTimeout(() => {
      window.location.href = href.path ? href.path() : href;
    }, 750);
  }
}

window.Fustrate = Fustrate;
window.$ = $;

export default Fustrate;
