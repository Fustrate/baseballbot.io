export function setChildren(parent: HTMLElement, items: HTMLElement[]): void {
  const fragment = document.createDocumentFragment();

  fragment.append(...items);

  parent.textContent = '';
  parent.append(fragment);
}

export function readFile(file: File, type: 'dataURL' | 'text', callback: (text: string) => void): void {
  const reader = new FileReader();

  reader.addEventListener('load', (event: ProgressEvent<FileReader>): void => {
    callback(String(event.target.result));
  });

  if (type === 'dataURL') {
    reader.readAsDataURL(file);
  } else {
    reader.readAsText(file);
  }
}

export function postAtFormat(postAt?: string): string {
  if (!postAt) {
    return '3 Hours Pregame';
  }

  if (/^-?\d{1,2}$/.test(postAt)) {
    return `${Math.abs(parseInt(postAt, 10))} Hours Pregame`;
  }

  if (/(1[012]|\d)(:\d\d|) ?(am|pm)/i.test(postAt)) {
    return `at ${postAt}`;
  }

  // Bad format, default back to 3 hours pregame
  return '3 Hours Pregame';
}
