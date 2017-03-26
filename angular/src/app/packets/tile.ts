import { Packet } from './packet';
import { RequestTileCss } from './request-tile-css';

export class Tile {

  description: String;
  name: String;
  occupants: number;
  plane: number;
  type: string;
  type_id: number;
  x: number;
  y: number;
  z: number;

  get id(): string {
    return [
      this.x,
      this.y,
      this.z,
      this.plane]
    .join(",");
  }

  get css(): RequestTileCss {
    return Object.assign(new RequestTileCss(),{coordinates: {
      x: this.x,
      y: this.y,
      z: this.z
    }});
  }
}
