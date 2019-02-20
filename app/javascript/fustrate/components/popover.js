import $ from 'jquery';

import Component from '../component';

class Popover extends Component {
  static initialize() {
    this.cache = {};
    this.container = $('.container-content > .row');

    $('[data-popover-url]').click(this.togglePopover);

    $('body').on('click.popover', this.hidePopover);
  }

  static togglePopover(event) {
    const path = event.currentTarget.dataset.popoverUrl;
    // Hide if the url is the same, hide and show a new one if it's different
    const createNew = (!Popover.popover) || (Popover.popover.data('popover-url') !== path);

    if (Popover.popover != null) {
      Popover.popover.hide().remove();
    }

    Popover.popover = undefined;

    if (createNew) {
      Popover.createPopover(event);
    }

    return false;
  }

  static createPopover(event) {
    const path = event.currentTarget.dataset.popoverUrl;

    Popover.popover = $('<div class="popover"></div>')
      .appendTo('body')
      .data('popover-url', path);

    if (Popover.cache[path]) {
      Popover.setContent(Popover.cache[path], event);
      Popover.popover.fadeIn(100);
    } else {
      $.get(path).done((html) => {
        Popover.cache[path] = html;
        Popover.setContent(html, event);
      });
    }
  }

  static setContent(html, event) {
    Popover.popover.html(html);

    const target = $(event.currentTarget);

    const css = {
      left: Popover.container.offset().left + 20,
      right: $(window).width() - target.offset().left + 10,
      overflow: 'scroll',
    };

    const windowHeight = $(window).height();
    // Distance scrolled from top of page
    const scrollTop = $(window).scrollTop();
    const offsetTop = target.offset().top;
    const height = target.outerHeight();
    const distanceFromTop = offsetTop - scrollTop;
    const distanceFromBottom = windowHeight + scrollTop - offsetTop - height;
    if (distanceFromTop < distanceFromBottom) {
      css.top = offsetTop - Math.min(distanceFromTop, 0) + 10;
      css.maxHeight = distanceFromBottom + height - 20;
    } else {
      css.bottom = windowHeight - target.position().top - height
        - Math.min(distanceFromBottom, 0) - 40;
      css.maxHeight = distanceFromTop - 10;
    }
    Popover.popover.css(css);
  }

  static hidePopover(event) {
    if (!Popover.popover) {
      return;
    }

    if ($(event.target).parents('.popover').length > 0) {
      return;
    }

    Popover.popover.hide().remove();

    Popover.popover = undefined;
  }
}

Component.register(Popover);

export default Popover;
