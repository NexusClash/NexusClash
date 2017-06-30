import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs/Observable';

import { Character } from '../../transport/models/character';
import { CharacterService } from '../../transport/services/character.service';

@Component({
  selector: 'app-attack',
  templateUrl: './attack.component.html',
  styleUrls: ['./attack.component.css']
})
export class AttackComponent {

  private target: Observable<Character> = this.route.params
    .switchMap(params => this.characterService.character(+params['other_id']));

  constructor(
      private characterService: CharacterService,
      private route: ActivatedRoute
  ) { }
}
