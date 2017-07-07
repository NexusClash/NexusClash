import { Packet } from './packet';

export class Learnable extends Packet {

  id: number;
  name: string;
  learned: boolean;
  children: Learnable[];
  description: string;
  cost: number;

  constructor(data?: any) {
    data = data || {};
    super(data.type, data);
  }
}
