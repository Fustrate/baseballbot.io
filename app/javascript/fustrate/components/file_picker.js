import Component from '../component';

// Turn any element into a trigger for file selection.
class FilePicker extends Component {
  constructor(callback) {
    super();

    const input = document.createElement('input');
    input.setAttribute('type', 'file');

    input.addEventListener('change', () => {
      callback(input.files);

      input.parentNode.removeChild(input);
    });

    document.body.appendChild(input);

    input.click();
  }
}

export default FilePicker;
