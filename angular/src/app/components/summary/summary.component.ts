import { Component, OnInit } from '@angular/core';

import { CharacterService } from '../../transport/services/character.service';
import { Character } from '../../transport/models/character';

@Component({
  selector: 'app-summary',
  templateUrl: './summary.component.html',
  styleUrls: ['./summary.component.css']
})
export class SummaryComponent implements OnInit {

  get character(): Character {
    return this.characterService.character;
  }
  constructor(
    private characterService: CharacterService
  ) { }

  ngOnInit() {
  }

}
