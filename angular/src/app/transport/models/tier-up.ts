import { Packet } from './packet';

export class TierUp extends Packet {

  id: number;
  tier: number;
  name: string;
  attributes: any[];

  constructor(data?: any) {
    data = data || {};
    super("class_choice", data);
  }

  indefiniteName(): string {
    return (this.name.match(/^[aeiou]/i) ? 'an ' : 'a ') + this.name;
  }
}
