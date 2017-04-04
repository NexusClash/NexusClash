import { Packet } from './packet';
import { Status } from './status';

export class Character extends Packet {
  id: number;
  name: String;
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
  nexus_class: String;
  sense_hp: Boolean;
  sense_mp: Boolean;
  sense_mo: Boolean;
  alignment: String;
  visible_statuses: Status[] = [];

  get locationId(): string {
    return [this.x,this.y,this.z,this.plane].join(',');
  }

  constructor(){
    super("character");
  }
}
