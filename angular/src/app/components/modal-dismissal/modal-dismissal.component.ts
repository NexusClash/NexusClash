import { Component, Input  } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

import { CharacterService } from '../../services/character.service';

@Component({
  selector: 'app-modal-dismissal',
  templateUrl: './modal-dismissal.component.html',
  styleUrls: ['./modal-dismissal.component.css']
})
export class ModalDismissalComponent {

  constructor(
      private characterService: CharacterService,
      private route: ActivatedRoute,
      private router: Router
  ) { }

  @Input() text: string;

  dismiss(): void {
    this.router.navigate([{ outlets: {
      primary: ['game', this.characterService.myId],
      popup: null,
    }}], { relativeTo: this.route.root });
  }

}
