import { Packet } from './packet';

export class Message extends Packet {
  class: String;
  message: String;
  timestamp: Date;

  constructor(){
    super();
    this.type = "message";
  }

}
