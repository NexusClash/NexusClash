import { Packet } from './packet';

export class Item extends Packet {

  id: number;
  name: string;
  category: number;
  weight: string;
  actions: {name: string, status_id: number}[];

  constructor(data?: any) {
    data = data || {};
    data.itemType = data["type"];
    super("item", data);
  }
}
