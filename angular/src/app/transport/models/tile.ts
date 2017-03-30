import { Packet } from './packet';

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
}
