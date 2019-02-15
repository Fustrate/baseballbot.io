import $ from 'jquery';

import Fustrate from '../fustrate';
import Component from '../component';

const settings = {
  previousText: '← Previous',
  nextText: 'Next →',
};

class Pagination extends Component {
  constructor({
    current_page, total_pages, total_entries, per_page,
  }) {
    super();

    this.current_page = current_page;
    this.total_pages = total_pages;
    this.total_entries = total_entries;
    this.per_page = per_page;

    this.base = this.constructor.getPreppedPaginationURL();
  }

  link(text, page, ...args) {
    return Fustrate.linkTo(text, `${this.base}page=${page}`, ...args);
  }

  previousLink() {
    if (this.current_page === 1) {
      return `
        <li class="previous_page unavailable">
          <a href="#">${settings.previousText}</a>
        </li>`;
    }

    const previous = this.link(settings.previousText, this.current_page - 1, {
      rel: 'prev',
    });

    return `<li class="previous_page">${previous}</li>`;
  }

  nextLink() {
    if (this.current_page < this.total_pages) {
      return `
        <li class="next_page unavailable">
          <a href="#">${settings.nextText}</a>
        </li>`;
    }

    const next = this.link(settings.nextText, this.current_page + 1, {
      rel: 'next',
    });

    return `<li class="next_page">${next}</li>`;
  }

  generate() {
    if (this.total_pages === 1) {
      return $('<ul class="pagination">');
    }

    const pages = this.windowedPageNumbers().map((page) => {
      if (page === this.current_page) {
        return `<li class="current">${Fustrate.linkTo(page, '#')}</li>`;
      }

      if (page === 'gap') {
        return '<li class="unavailable"><span class="gap">…</span></li>';
      }

      return `<li>${this.link(page, page)}</li>`;
    });

    pages.unshift(this.previousLink());
    pages.push(this.nextLink());

    return $('<ul class="pagination">').html(pages.join(' '));
  }

  windowedPageNumbers() {
    let pages = [];

    let windowFrom = this.current_page - 4;
    let windowTo = this.current_page + 4;

    if (windowTo > this.total_pages) {
      windowFrom -= windowTo - this.total_pages;
      windowTo = this.total_pages;
    }

    if (windowFrom < 1) {
      windowTo += 1 - windowFrom;
      windowFrom = 1;

      if (windowTo > this.total_pages) {
        windowTo = this.total_pages;
      }
    }

    if (windowFrom > 4) {
      pages = [1, 2, 'gap'];
    } else {
      for (let i = 1; i < windowFrom; i += 1) {
        pages.push(i);
      }
    }

    for (let i = windowFrom; i < windowTo; i += 1) {
      pages.push(i);
    }

    if (this.total_pages - 3 > pages[pages.length - 1]) {
      pages.push('gap');
      pages.push(this.total_pages - 1);
      pages.push(this.total_pages);
    } else if (pages[pages.length - 1] + 1 <= this.total_pages) {
      for (let i = pages[pages.length - 1] + 1; i <= this.total_pages; i += 1) {
        pages.push(i);
      }
    }

    return pages;
  }

  static getCurrentPage() {
    const matchData = window.location.search.match(/[?&]page=(\d+)/);

    if (matchData != null) {
      return matchData[0];
    }

    return 1;
  }

  // Just add 'page='
  static getPreppedPaginationURL() {
    const url = window.location.search.replace(/[?&]page=\d+/, '');

    if (url[0] === '?') {
      return `${window.location.pathname}${url}&`;
    }

    if (url[0] === '&') {
      return `${window.location.pathname}?${url.slice(1, url.length)}&`;
    }

    return `${window.location.pathname}?`;
  }
}

export default Pagination;
