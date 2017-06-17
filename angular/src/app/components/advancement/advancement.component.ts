import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

import { AdvancementService } from '../../transport/services/advancement.service';
import { CharacterService } from '../../transport/services/character.service';

@Component({
  selector: 'app-advancement',
  templateUrl: './advancement.component.html',
  styleUrls: ['./advancement.component.css']
})
export class AdvancementComponent {

  constructor(
    private advancementService: AdvancementService,
    private characterService: CharacterService,
    private route: ActivatedRoute,
    private router: Router
  ) { }

  dismiss(): void {
    this.router.navigate([{ outlets: {
      primary: ['game', this.characterService.myId],
      popup: null,
    }}], { relativeTo: this.route.root });
  }
}