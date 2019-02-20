import $ from 'jquery';

import Component from '../component';

const fadeSpeed = 100;

class Tooltip extends Component {
  constructor(element, title) {
    super();

    this.element = $(element);
    this.active = false;
    this.addEventListeners();

    if (title) {
      this.element.attr('title', title);
    }
  }

  addEventListeners() {
    this.element
      .off('.tooltip')
      .on('mouseenter.tooltip', this.show)
      .on('mousemove.tooltip', this.move)
      .on('mouseleave.tooltip', this.hide);
  }

  setTitle(title) {
    if (this.active) {
      this.tooltip.text(title);
    } else {
      this.element.prop('title', title);
    }
  }

  move(e) {
    if (this.active) {
      this.tooltip.css(this.tooltipPosition(e));
    }

    return false;
  }

  show(e) {
    if (this.active) {
      return false;
    }

    const titleProp = this.element.prop('title');
    const title = titleProp != null ? titleProp : '';

    if (title.length === 0) {
      return false;
    }

    if (this.tooltip == null) {
      this.tooltip = $('<span class="tooltip">').hide();
    }

    this.element.attr('title', '').removeAttr('title');
    this.active = true;
    this.tooltip
      .text(title)
      .appendTo($('body'))
      .css(this.tooltipPosition(e))
      .fadeIn(fadeSpeed);

    return false;
  }

  hide() {
    // No use hiding something that doesn't exist.
    if (this.tooltip) {
      this.element.attr('title', this.tooltip.text());
      this.active = false;
      this.tooltip.fadeOut(fadeSpeed, this.tooltip.detach);
    }

    return false;
  }

  static tooltipPosition(e) {
    return {
      top: `${e.pageY + 15}px`,
      left: `${e.pageX - 10}px`,
    };
  }

  static initialize() {
    $('[data-tooltip]').each((index, elem) => new Tooltip(elem));

    $.fn.extend({
      tooltip: () => this.each((index, element) => new Tooltip(element)),
    });
  }
}

Component.register(Tooltip);

export default Tooltip;
