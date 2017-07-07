import { Packet } from './packet';

export class ChargeAttack extends Packet {

  id: number;
  name: string;
  description: string;
  possible: boolean;

  constructor(data?: any) {
    data = data || {};
    super("charge-attack", data);
  }
}
