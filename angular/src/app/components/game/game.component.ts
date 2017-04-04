import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';

import { AuthService } from '../../transport/services/auth.service';
import { Character } from '../../transport/models/character';
import { CharacterService } from '../../transport/services/character.service';

@Component({
  selector: 'app-game',
  templateUrl: './game.component.html',
  styleUrls: ['./game.component.css']
})
export class GameComponent implements OnInit {

  showDebugMessages: Boolean = false;
  showPacketTraffic: Boolean = false;

  character = this.characterService.myself;

  constructor(
    private route: ActivatedRoute,
    private authService: AuthService,
    private characterService: CharacterService
  ){ }

  ngOnInit() {
    this.authService.characterId = +this.route.snapshot.params['id'];
  }
}
