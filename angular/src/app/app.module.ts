import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';


import { AppRoutingModule } from './app-routing.module';

import { AppComponent } from './app.component';
import { AdvancementComponent } from './components/advancement/advancement.component';
import { BasicActionsComponent } from './components/basic-actions/basic-actions.component';
import { GameComponent } from './components/game/game.component';
import { DebugComponent } from './components/debug/debug.component';
import { MapComponent } from './components/map/map.component';
import { MessageComponent } from './components/message/message.component';
import { SummaryComponent } from './components/summary/summary.component';
import { TileComponent } from './components/tile/tile.component';
import { DescriptionComponent } from './components/description/description.component';
import { TargetableCharacterComponent } from './components/targetable-character/targetable-character.component';
import { SpeechComponent } from './components/speech/speech.component';
import { LearnableComponent } from './components/learnable/learnable.component';
import { ChangeClassComponent } from './components/change-class/change-class.component';
import { AttackComponent } from './components/attack/attack.component';
import { ModalDismissalComponent } from './components/modal-dismissal/modal-dismissal.component';
import { InventoryComponent } from './components/inventory/inventory.component';

import { AbilityService } from './services/ability.service';
import { AdvancementService } from './services/advancement.service';
import { AttackService } from './services/attack.service';
import { AuthService } from './services/auth.service';
import { BasicService } from './services/basic.service';
import { CharacterService } from './services/character.service';
import { InventoryService } from './services/inventory.service';
import { MessageService } from './services/message.service';
import { SocketService } from './services/socket.service';
import { TileService } from './services/tile.service';

import { RefreshInventoryGuard } from './guards/refresh-inventory.guard';

@NgModule({
  declarations: [
    AppComponent,
    BasicActionsComponent,
    DebugComponent,
    GameComponent,
    MapComponent,
    MessageComponent,
    SummaryComponent,
    TileComponent,
    DescriptionComponent,
    TargetableCharacterComponent,
    SpeechComponent,
    AdvancementComponent,
    LearnableComponent,
    ChangeClassComponent,
    AttackComponent,
    ModalDismissalComponent,
    InventoryComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    AppRoutingModule
  ],
  providers: [
    AbilityService,
    AdvancementService, AttackService, AuthService,
    BasicService, CharacterService, InventoryService,
    MessageService, SocketService, TileService,

    RefreshInventoryGuard
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
