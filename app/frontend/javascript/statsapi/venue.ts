export interface Venue {
  id: number;
  link: string;
  name: string;
  location: {
    city: string;
    state: string;
    stateAbbrev: string;
    defaultCoordinates: {
      latitude: number;
      longitude: number;
    };
  };
  timeZone: {
    id: string;
    offset: number;
    tz: string;
  };
  fieldInfo: {
    capacity: number;
    turfType: 'Grass' | 'Artificial';
    roofType: 'Open' | 'Retractable';
    leftLine: number;
    left: number;
    center: number;
    right: number;
    rightLine: number;
  };
}
