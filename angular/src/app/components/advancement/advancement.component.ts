import { Component, OnInit } from '@angular/core';

import { AdvancementService } from '../../transport/services/advancement.service';
import { CharacterService } from '../../transport/services/character.service';

@Component({
  selector: 'app-advancement',
  templateUrl: './advancement.component.html',
  styleUrls: ['./advancement.component.css']
})
export class AdvancementComponent implements OnInit {

  constructor(
    private advancementService: AdvancementService,
    private characterService: CharacterService
  ) { }

  ngOnInit(): void {
    this.advancementService.getSkillTree();
  }
}
