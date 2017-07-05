import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs/Observable';

import { Character } from '../../transport/models/character';
import { AttackService } from '../../transport/services/attack.service';
import { CharacterService } from '../../transport/services/character.service';

@Component({
  selector: 'app-attack',
  templateUrl: './attack.component.html',
  styleUrls: ['./attack.component.css']
})
export class AttackComponent {

  private selectedChargeAttackId:number = 0;
  private target: Observable<Character> = this.route.params
    .map(params => +params['other_id'])
    .switchMap(targetId => {
      this.characterService.doWhenCharacterIsKnown(() =>
        this.attackService.selectTarget(targetId));
      return this.characterService.character(targetId);
    });

  constructor(
    private attackService: AttackService,
    private characterService: CharacterService,
    private route: ActivatedRoute
  ) { }

  private performAttack(attackId: number): void {
    this.attackService.attack(attackId, this.selectedChargeAttackId);
  }
}
