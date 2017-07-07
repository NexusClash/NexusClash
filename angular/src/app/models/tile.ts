import { Packet } from './packet';

export class Tile extends Packet {

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
    return [this.x,this.y,this.z,this.plane].join(',');
  }

  get autowiki(): string {
    return ["","autowiki","tile", this.x, this.y, this.z].join("/");
  }

  constructor(data?: any) {
    super("tile", data);
  }
}
