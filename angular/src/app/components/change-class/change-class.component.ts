import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

import { AdvancementService } from '../../services/advancement.service';
import { CharacterService } from '../../services/character.service';

@Component({
  selector: 'app-change-class',
  templateUrl: './change-class.component.html',
  styleUrls: ['./change-class.component.css']
})
export class ChangeClassComponent {

  constructor(
    private advancementService: AdvancementService,
    private characterService: CharacterService,
    private route: ActivatedRoute,
    private router: Router
  ) { }

  chooseClass(id: number): void {
    this.advancementService.purchase(id);
    this.router.navigate([{ outlets: {
      primary: ['game', this.characterService.myId],
      popup: null,
    }}], { relativeTo: this.route.root });
    this.advancementService.refreshChoices();
  }

  switchToBuySkills(): void {
    this.router.navigate([{ outlets: {
      popup: 'buy-skills'
    }}], { relativeTo: this.route.parent });
  }
}
