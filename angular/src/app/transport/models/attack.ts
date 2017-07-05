import { Packet } from './packet';

export class Attack extends Packet {

  id: number;
  name: string;
  hit_chance: number; // percentage
  damage: string; // number or formula
  damage_type: string;
  cost: number;

  constructor(data?: any) {
    data = data || {};
    super("attack", data);
  }
}
