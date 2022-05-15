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
