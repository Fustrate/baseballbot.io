import $ from 'jquery';

import Component from '../component';

const fadeSpeed = 300;

class AlertBox extends Component {
  static initialize() {
    return $('.alert-box').on('click', '.close', (e) => {
      const alertBox = $(e.currentTarget).closest('.alert-box');

      alertBox.fadeOut(fadeSpeed, alertBox.remove);

      return false;
    });
  }
}

Component.register(AlertBox);

export default AlertBox;
