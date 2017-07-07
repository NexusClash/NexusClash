import { Packet } from './packet';

export class Message extends Packet {
  class: string;
  message: string;
  timestamp: number; // seconds since epoch

  get dateTime(): Date {
    return this.timestamp
      ? new Date(this.timestamp * 1000)
      : null;
  }

  constructor(data?: any){
    super("message", data);
  }

}
