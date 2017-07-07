import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';

import { AuthService } from '../../services/auth.service';
import { Character } from '../../models/character';
import { CharacterService } from '../../services/character.service';
import { Tile } from '../../models/tile';
import { TileService } from '../../services/tile.service';

@Component({
  selector: 'app-game',
  templateUrl: './game.component.html',
  styleUrls: ['./game.component.css']
})
export class GameComponent implements OnInit {

  showDebugMessages: Boolean = false;
  showPacketTraffic: Boolean = false;

  character: Subject<Character> = this.characterService.myself;
  tile: Observable<Tile> = this.characterService.myself
    .switchMap(character => this.tileService.tile(character.locationId));

  constructor(
    private route: ActivatedRoute,
    private authService: AuthService,
    private characterService: CharacterService,
    private tileService: TileService
  ){ }

  ngOnInit() {
    this.authService.characterId = +this.route.snapshot.params['id'];
  }
}
