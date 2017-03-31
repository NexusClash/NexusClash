import { Packet } from './packet';

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

  constructor(){
    super("character");
  }

}
