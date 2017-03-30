import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

import { AppComponent } from './app.component';

import { AuthService } from './transport/services/auth.service';
import { CharacterService } from './transport/services/character.service';
import { MessageService } from './transport/services/message.service';
import { SocketService } from './transport/services/socket.service';
import { TileService } from './transport/services/tile.service';
import { DebugComponent } from './components/debug/debug.component';
import { MapComponent } from './components/map/map.component';
import { MessageComponent } from './components/message/message.component';
import { SummaryComponent } from './components/summary/summary.component';
import { TileComponent } from './components/tile/tile.component';

@NgModule({
  declarations: [
    AppComponent,
    DebugComponent,
    MapComponent,
    MessageComponent,
    SummaryComponent,
    TileComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule
  ],
  providers: [
    AuthService, CharacterService, MessageService,
    SocketService, TileService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
