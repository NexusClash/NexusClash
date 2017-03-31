import { Component, EventEmitter, Input, Output } from '@angular/core';

import { Character } from '../../transport/models/character';

@Component({
  selector: 'app-targetable-character',
  templateUrl: './targetable-character.component.html',
  styleUrls: ['./targetable-character.component.css']
})
export class TargetableCharacterComponent {

  @Input() character: Character;
  @Output() select = new EventEmitter();

  constructor() { }
}
