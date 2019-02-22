import Fustrate from '..';
import Component from '../component';

const settings = {
  previousText: '← Previous',
  nextText: 'Next →',
};

class Pagination extends Component {
  constructor({
    currentPage, totalPages, totalEntries, perPage,
  }) {
    super();

    this.currentPage = currentPage;
    this.totalPages = totalPages;
    this.totalEntries = totalEntries;
    this.perPage = perPage;

    this.base = this.constructor.getPreppedPaginationURL();
  }

  link(text, page, ...args) {
    return Fustrate.linkTo(text, `${this.base}page=${page}`, ...args);
  }

  previousLink() {
    if (this.currentPage === 1) {
      return `
        <li class="previous_page unavailable">
          <a href="#">${settings.previousText}</a>
        </li>`;
    }

    const previous = this.link(settings.previousText, this.currentPage - 1, { rel: 'prev' });

    return `<li class="previous_page">${previous}</li>`;
  }

  nextLink() {
    if (this.currentPage < this.totalPages) {
      return `
        <li class="next_page unavailable">
          <a href="#">${settings.nextText}</a>
        </li>`;
    }

    const next = this.link(settings.nextText, this.currentPage + 1, { rel: 'next' });

    return `<li class="next_page">${next}</li>`;
  }

  generate() {
    if (this.totalPages === 1) {
      return '<ul class="pagination"></ul>';
    }

    const pages = this.windowedPageNumbers().map((page) => {
      if (page === this.currentPage) {
        return `<li class="current">${Fustrate.linkTo(page, '#')}</li>`;
      }

      if (page === 'gap') {
        return '<li class="unavailable"><span class="gap">…</span></li>';
      }

      return `<li>${this.link(page, page)}</li>`;
    });

    pages.unshift(this.previousLink());
    pages.push(this.nextLink());

    return `<ul class="pagination">${pages.join('')}</ul>`;
  }

  windowedPageNumbers() {
    let pages = [];

    let windowFrom = this.currentPage - 4;
    let windowTo = this.currentPage + 4;

    if (windowTo > this.totalPages) {
      windowFrom -= windowTo - this.totalPages;
      windowTo = this.totalPages;
    }

    if (windowFrom < 1) {
      windowTo += 1 - windowFrom;
      windowFrom = 1;

      if (windowTo > this.totalPages) {
        windowTo = this.totalPages;
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

    if (this.totalPages - 3 > pages[pages.length - 1]) {
      pages.push('gap');
      pages.push(this.totalPages - 1);
      pages.push(this.totalPages);
    } else if (pages[pages.length - 1] + 1 <= this.totalPages) {
      for (let i = pages[pages.length - 1] + 1; i <= this.totalPages; i += 1) {
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
