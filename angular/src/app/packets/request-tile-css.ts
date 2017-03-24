import { Packet } from './packet';

export class RequestTileCss extends Packet {

  coordinates: {
    x: number,
    y: number,
    z: number
  }

  constructor(){
    super();
    this.type = "request_tile_css";
  }
}
