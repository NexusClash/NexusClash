import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

import { AppRoutingModule } from './app-routing.module';
import { AuthService } from './transport/services/auth.service';
import { BasicService } from './transport/services/basic.service';
import { CharacterService } from './transport/services/character.service';
import { MessageService } from './transport/services/message.service';
import { SocketService } from './transport/services/socket.service';
import { TileService } from './transport/services/tile.service';
import { AppComponent } from './app.component';
import { BasicActionsComponent } from './components/basic-actions/basic-actions.component';
import { GameComponent } from './components/game/game.component';
import { DebugComponent } from './components/debug/debug.component';
import { MapComponent } from './components/map/map.component';
import { MessageComponent } from './components/message/message.component';
import { SummaryComponent } from './components/summary/summary.component';
import { TileComponent } from './components/tile/tile.component';
import { DescriptionComponent } from './components/description/description.component';
import { TargetableCharacterComponent } from './components/targetable-character/targetable-character.component';

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
    TargetableCharacterComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    AppRoutingModule
  ],
  providers: [
    AuthService, BasicService, CharacterService,
    MessageService, SocketService, TileService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
