import { Packet } from './packet';
import { Status } from './status';

export class Character extends Packet {
  id: number;
  name: string;
  hp: number;
  hp_max: number;
  ap: number;
  mp: number;
  mp_max: number;
  xp: number;
  level: number;
  mo: number;
  cp: number;
  x: number;
  y: number;
  z: number;
  plane: number
  nexus_class: string;
  sense_hp: Boolean;
  sense_mp: Boolean;
  sense_mo: Boolean;
  alignment: string;
  visible_statuses: Status[] = [];

  get locationId(): string {
    return [this.x,this.y,this.z,this.plane].join(',');
  }

  constructor(){
    super("character");
  }
}
