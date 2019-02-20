import $ from 'jquery';

import Component from '../component';

class Tabs extends Component {
  constructor(tabs) {
    super();

    this.tabs = tabs;
    this.tabs.on('click', 'li > a', (e) => {
      this.activateTab($(e.currentTarget), true);
      return false;
    });

    if (window.location.hash) {
      this.activateTab($(`li > a[href='${window.location.hash}']`, this.tabs).first(), false);
    } else if ($('li > a.active', this.tabs).length > 0) {
      this.activateTab($('li > a.active', this.tabs).first(), false);
    } else {
      this.activateTab($('li > a', this.tabs).first(), false);
    }
  }

  activateTab(tab, changeHash) {
    if (tab.length === 0) {
      return;
    }

    $('.active', this.tabs).removeClass('active');
    tab.addClass('active');
    const hash = tab.attr('href').split('#')[1];

    if (changeHash) {
      window.location.hash = hash;
    }

    $(`#${hash}`).addClass('active').siblings().removeClass('active');
  }

  static initialize() {
    $('ul.tabs').each((index, elem) => new Tabs($(elem)));
  }
}

Component.register(Tabs);

export default Tabs;
