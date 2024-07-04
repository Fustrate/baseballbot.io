import Color from 'color';

const variables = {
  'fa-weight-light': 300,
  'fa-weight-regular': 400,
  'fa-weight-solid': 900,
  'body-bg': '#f4f4f4',
  'content-bg': '#fff',
  'primary-color': '#0b2d4d',
  'secondary-color': '#e7e7e7',
};

const palette = {
  // Primary
  'primary-050': Color('#DCEEFB'),
  'primary-100': Color('#B6E0FE'),
  'primary-200': Color('#84C5F4'),
  'primary-300': Color('#62B0E8'),
  'primary-400': Color('#4098D7'),
  'primary-500': Color('#2680C2'),
  'primary-600': Color('#186FAF'),
  'primary-700': Color('#0F609B'),
  'primary-800': Color('#0A558C'),
  'primary-900': Color('#003E6B'),

  'secondary-050': Color('#FFFBEA'),
  'secondary-100': Color('#FFF3C4'),
  'secondary-200': Color('#FCE588'),
  'secondary-300': Color('#FADB5F'),
  'secondary-400': Color('#F7C948'),
  'secondary-500': Color('#F0B429'),
  'secondary-600': Color('#DE911D'),
  'secondary-700': Color('#CB6E17'),
  'secondary-800': Color('#B44D12'),
  'secondary-900': Color('#8D2B0B'),

  'neutral-050': Color('#F0F4F8'),
  'neutral-100': Color('#D9E2EC'),
  'neutral-200': Color('#BCCCDC'),
  'neutral-300': Color('#9FB3C8'),
  'neutral-400': Color('#829AB1'),
  'neutral-500': Color('#627D98'),
  'neutral-600': Color('#486581'),
  'neutral-700': Color('#334E68'),
  'neutral-800': Color('#243B53'),
  'neutral-900': Color('#102A43'),

  'supporting-050': Color('#E0FCFF'),
  'supporting-100': Color('#BEF8FD'),
  'supporting-200': Color('#87EAF2'),
  'supporting-300': Color('#54D1DB'),
  'supporting-400': Color('#38BEC9'),
  'supporting-500': Color('#2CB1BC'),
  'supporting-600': Color('#14919B'),
  'supporting-700': Color('#0E7C86'),
  'supporting-800': Color('#0A6C74'),
  'supporting-900': Color('#044E54'),

  'red-050': Color('#FFEEEE'),
  'red-100': Color('#FACDCD'),
  'red-200': Color('#F29B9B'),
  'red-300': Color('#E66A6A'),
  'red-400': Color('#D64545'),
  'red-500': Color('#BA2525'),
  'red-600': Color('#A61B1B'),
  'red-700': Color('#911111'),
  'red-800': Color('#780A0A'),
  'red-900': Color('#610404'),

  'green-050': Color('#F2FDE0'),
  'green-100': Color('#E2F7C2'),
  'green-200': Color('#C7EA8F'),
  'green-300': Color('#ABDB5E'),
  'green-400': Color('#94C843'),
  'green-500': Color('#7BB026'),
  'green-600': Color('#63921A'),
  'green-700': Color('#507712'),
  'green-800': Color('#42600C'),
  'green-900': Color('#2B4005'),
};

for (const key of Object.keys(palette)) {
  variables[key] = palette[key].string();
}

Object.assign(variables, {
  red: palette['red-700'].string(),
  orange: palette['secondary-600'].string(),
  yellow: palette['secondary-300'].string(),
  green: '#79ae3d',
  blue: palette['primary-600'].string(),
  purple: '#653CAD',
  pink: '#F364A2',
  brown: '#8b5e36',
  grey: palette['neutral-500'].string(),
  white: '#fff',
  black: '#000',
});

Object.assign(variables, {
  'base-line-height': '150%',
  'font-family': "-apple-system, BlinkMacSystemFont, Roboto, 'Helvetica Neue', Helvetica, Arial, sans-serif",
  'text-color': '#222',
  'border-radius': '6px',
});

Object.assign(variables, {
  'table-border-color': '#ddd',
});

// Design
Object.assign(variables, {
  'edited-field-del-color': 'hsl(360, 85%, 25%)',
  'edited-field-ins-color': 'hsl(125, 73%, 20%)',
});

// fustrate-rails
Object.assign(variables, {
  // Component: Alerts
  'alert-padding': '0.5rem 1.5rem 0.5rem 0.875rem',
  'alert-font-size': '0.875rem',
  'alert-dark-color': '#333',
  'alert-light-color': '#fff',
  'alert-default-color': '#eaeaea',

  // Component: Buttons
  'button-padding': '0.75rem',
  'button-font-size': '0.75rem',
  'button-color': '#fff',
  'button-alt-color': '#333',

  // Component: Disclosures
  'disclosure-title-font-size': '0.75rem',

  // Component: Dropdowns
  'dropdown-color': '#000',
  'dropdown-bg-color': '#fff',
  'dropdown-border-color': '#ccc',
  'dropdown-hover-bg-color': '#f4f4f4',
  'dropdown-icon': String.raw`'\25BE'`,

  // Component: Flash
  'flash-color': '#fff',
  'flash-shadow-color': 'rgba(255, 255, 255, .4)',
  'flash-bg-color': variables['primary-600'],
  'flash-error-bg-color': variables['red-500'],
  'flash-success-bg-color': variables.green,

  // Component: Forms
  'form-element-border-radius': '0',
  'form-spacing': '1rem',
  'form-button-border-radius': '0',
  'form-disabled-bg-color': '#ddd',
  'form-disabled-color': '#777',
  'form-element-margin': '0 0 0.5rem 0',
  'form-element-shadow-color': 'rgba(0, 0, 0, .1)',
  'form-input-font-size': '0.875rem',
  'form-label-color': '#4d4d4d',
  'form-label-font-size': '0.875rem',

  // Component: Labels
  'label-padding': '0.375rem 0.5rem',
  'label-font-size': '0.75rem',
  'label-font-color': '#333',
  'label-font-color-alt': '#fff',
  'label-plain-color': '#eee',

  // Component: Modals
  'modal-bg-color': '#fff',
  'modal-border-color': '#666',
  'modal-cancel-button-color': '#dadada',
  'modal-overlay-color': 'rgba(0, 0, 0, .45)',
  'modal-title-color': '#fff',

  // Component: Pagination
  'pagination-active-bg-color': variables['primary-600'],
  'pagination-active-color': '#fff',
  'pagination-color': '#222',
  'pagination-disabled-color': '#999',
  'pagination-hover-bg-color': 'rgba(0, 0, 0, .08)',
  'pagination-link-color': '#999',

  // Component: Panels
  'panel-bg': '#f2f2f2',
  'panel-font-color-alt': '#fff',
  'panel-font-color': '#333',
  'panel-margin-bottom': '1.25rem',
  'panel-padding-small': '0.5rem 0.625rem',
  'panel-padding': '1rem 1.25rem',

  // Component: Tables
  'table-border-color': '#ccc',
  'table-padding': '.5em',
  'table-header-border-color': Color('#ccc').darken(0.25).string(),

  // Component: Tabs
  'tabs-active-color': variables['primary-600'],
  'tabs-bg-color': '#fff',
  'tabs-content-padding': '0 0.625rem',
  'tabs-font-size': '0.75rem',
  'tabs-padding': '0.625rem',

  // Component: Tooltips
  'tooltip-bg-color': '#222',
  'tooltip-color': '#eee',
  'tooltip-opacity': '.9',
});

export default variables;
